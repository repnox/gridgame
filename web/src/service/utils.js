export function numToHex(num) {
    return num.toString(16).toUpperCase();
}

export function readFileAsBinaryString(file) {
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
}

export function readJsonFromZip(zip, filename) {
    const data = zip.files[filename];
    return JSON.parse(new TextDecoder().decode(data._data.getContent()));
}