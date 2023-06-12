# generate ABI in `out/CONTRACT_NAME.sol/CONTRACT_NAME.json`
forge b --skip test script


forge script ./script/Deploy.s.sol -f http://127.0.0.1:8545 --broadcast --json


python3 update_contracts.py