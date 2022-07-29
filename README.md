# zkASM Storage Compiler
This repo compiles .zkasm storage to a json file

## Setup
```
npm install
npm run build
```
## Usage
Generate json file from zkasm storage file:
```sh
node src/zkasmstorage.js <inputFile.zkasm> -o <outFile.json>
```
Example:
```sh
node src/zkasmstorage.js zkasm/storage_sm.zkasm -o build/storage_sm_rom.json
```
or
```sh
npm run build:rom
```
## License

### Copyright
Polygon `zkevm-storage-rom` was developed by Polygon. While we plan to adopt an open source license, we haven’t selected one yet, so all rights are reserved for the time being. Please reach out to us if you have thoughts on licensing.

### Disclaimer
This code has not yet been audited, and should not be used in any production systems.
