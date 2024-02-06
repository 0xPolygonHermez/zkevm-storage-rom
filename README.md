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
