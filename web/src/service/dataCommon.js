export default {
    getItemType(itemId) {
        return this.getByte(itemId, 32);
    },
    getItemSubtype(itemId) {
        return this.getByte(itemId, 32+4);
    },
    getByte(str, bytesFromRight) {
        let minLength = bytesFromRight + 3;
        if (str.length >= minLength) {
            // Discard the 0x
            let hex = str.substring(2);
            // Get the byte
            return hex.substring(hex.length - bytesFromRight - 1, hex.length - bytesFromRight);
        } else {
            return "0";
        }
    },
    getTileType(tileId) {
        if (!tileId) {
            return "0";
        } else {
            return tileId.substring(tileId.length-1);
        }
    }
}