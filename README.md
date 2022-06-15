# zkASM Compiler

This repo compiles .zkasm to a json ready for the zkExecutor

## Usage

`````
npm install
npm run build

node src/zkasmstorage.js [inputFile.zkasm] -o [outFile.json]

`````
## Example storage ROM generation
`````
node src/zkasmstorage.js zkasm/storage_sm.zkasm -o build/storage_sm_rom.json
`````
