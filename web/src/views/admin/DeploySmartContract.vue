<template>
  <b-container fluid class="full-height">
    <b-container class="pt-4">
      <b-row>
        <b-col>
          <h1 class="my-4">Deployment Package</h1>
          <b-form-file
              v-model="deploymentZip"
              :state="Boolean(deploymentZip)"
              placeholder="Choose a file or drop it here..."
              drop-placeholder="Drop file here..."
              accept=".zip"
          ></b-form-file>
        </b-col>
      </b-row>
      <b-row class="mt-4">
        <b-col>
          <b-button variant="primary" @click="readZipFile()">Read File</b-button>
        </b-col>
      </b-row>
      <b-row>
        <b-col>
          <div>
            Application Registry Address
          </div>
          <b-input v-model="applicationRegistry.address" />
        </b-col>
      </b-row>
      <b-row v-for="step in deploymentManifest" :key="step.filename">
        <b-col>
          <h3 class="mt-4">{{step.data.sourceName}}</h3>
          <b-row v-for="arg in step.metadata.args" :key="arg.name">
            <b-col cols="2">
              {{arg.name}}:
            </b-col>
            <b-col>
              <b-input v-model="arg.value" />
            </b-col>
          </b-row>
          <b-button @click="deployContract(step)">Deploy</b-button>
          <b-button @click="registerContract(step)" v-if="Boolean(step.metadata.registration)">Register</b-button>
          <b-alert class="mt-4" variant="success" :show="true" v-if="Boolean(step.successMessage)">
            <p v-html="step.successMessage"></p>
          </b-alert>
          <b-alert class="mt-4" variant="error" :show="true" v-if="Boolean(step.errorMessage)">
            <p v-html="step.errorMessage"></p>
          </b-alert>
        </b-col>
      </b-row>
    </b-container>
  </b-container>
</template>

<script>
import web3common from "../../service/web3common";
import {ContractFactory} from "ethers";
import nodezip from "node-zip";

export default {
  name: "DeploySmartContract.vue",
  data() {
    return {
      deploymentZip: null,
      deploymentManifest: [],
      applicationRegistry: {
        address: "",
      },
    }
  },
  methods: {
    async deployContract(deploymentStep) {
      try {
        deploymentStep.errorMessage = "";
        console.log(deploymentStep);
        const signer = await web3common.getSigner();
        const factory = new ContractFactory(deploymentStep.data.abi, deploymentStep.data.bytecode, signer);
        const args = [];
        for (let i in deploymentStep.metadata.args) {
          args.push(deploymentStep.metadata.args[i].value);
        }
        const contract = await factory.deploy(...args);
        this.$set(deploymentStep, "successMessage", "Created contract "+contract.address);
        this.$set(deploymentStep, "address", contract.address);
        this.prefillAddress(deploymentStep.data.contractName, contract.address);
        if (deploymentStep.data.contractName === "ApplicationRegistry") {
          this.applicationRegistry = deploymentStep;
        }
      } catch(err) {
        this.$set(deploymentStep, "errorMessage", "Deployment Error");
        throw err;
      }
    },
    async registerContract(deploymentStep) {
      try {
        deploymentStep.errorMessage = "";
        let appRegContract = await web3common.getContract(this.applicationRegistry.data.abi, this.applicationRegistry.address);
        await appRegContract[deploymentStep.metadata.registration](deploymentStep.address);
        deploymentStep.successMessage += "<br/>Registered.";
      } catch(err) {
        this.$set(deploymentStep, "errorMessage", "Registration Error");
        throw err;
      }
    },
    prefillAddress(contractName, contractAddress) {
      for (let step of this.deploymentManifest) {
        if (step.metadata && step.metadata.args) {
          for (let arg of step.metadata.args) {
            if (arg.name === contractName) {
              arg.value = contractAddress;
            }
          }
        }
      }
    },
    readFile(file) {
      return new Promise((resolve, reject) => {
        const fileReader = new FileReader();
        fileReader.onload = (res) => {
          resolve(res.target.result);
        };
        fileReader.onerror = (err) => {
          reject(JSON.stringify(err));
        };
        fileReader.readAsBinaryString(file)
      });
    },
    readZipFile() {
      this.readFile(this.deploymentZip).then((result) => {
        const zip = nodezip(result);
        const content = this.readJsonFromZip(zip, '_deploymentManifest');
        for (let step of content) {
          step.successMessage = "";
          step.errorMessage = "";
        }
        this.deploymentManifest = content;
      });

    },
    readJsonFromZip(zip, filename) {
      const data = zip.files[filename];
      const json = JSON.parse(new TextDecoder().decode(data._data.getContent()));
      return json;
    }
  }
}
</script>