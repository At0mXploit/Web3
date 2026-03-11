// Yul is an intermediate language for the EVM
// it sits between Solidity and raw bytecode
// you control memory, storage, and calldata manually
// no implicit ABI encoding, no automatic reverts, everything is explicit
// Yul uses objects and code blocks instead of contracts and functions

object "HorseStore" {

    // this code block runs ONLY at deployment
    // it copies the runtime code into memory and returns it to the EVM
    // after this runs, the runtime code becomes the deployed contract bytecode
    code {

        // datacopy copies the runtime object bytecode into memory
        // destination: memory offset 0
        // source: dataoffset of the runtime object
        // size: datasize of the runtime object
        datacopy(0x00, dataoffset("HorseStore_runtime"), datasize("HorseStore_runtime"))

        // return the runtime bytecode to the EVM so it gets stored on chain
        // this is what finalizes deployment
        return(0x00, datasize("HorseStore_runtime"))
    }

    // this is the actual contract code that lives on chain after deployment
    // every time someone calls this contract, this block executes
    object "HorseStore_runtime" {
        code {

            // STORAGE LAYOUT
            // numberOfHorses is stored at slot 0
            // same as Solidity — first state variable = slot 0
            // no variable declaration needed in Yul, slots are just numbers

            // DISPATCHER
            // every EVM call starts here
            // we read the first 4 bytes of calldata = function selector
            // then jump to the right function handler

            // calldataload(0) loads 32 bytes from calldata starting at offset 0
            // the function selector is the first 4 bytes (leftmost / most significant)
            // we shift right by 28 bytes (224 bits) to isolate just the 4 selector bytes
            // shr(224, calldataload(0)) = first 4 bytes of calldata as a uint32
            let selector := shr(224, calldataload(0))

            // updateHorseNumber(uint256) selector
            // keccak256("updateHorseNumber(uint256)") first 4 bytes = 0xcdfead2e
            // eq() returns 1 if equal, 0 if not
            // if() in Yul takes a condition and a block, no else
            if eq(selector, 0xcdfead2e) {
                // jump to our updateHorseNumber handler
                updateHorseNumber()
            }

            // readNumberOfHorses() selector
            // keccak256("readNumberOfHorses()") first 4 bytes = 0xe026c017
            if eq(selector, 0xe026c017) {
                // jump to our readNumberOfHorses handler
                readNumberOfHorses()
            }

            // if no selector matched, we revert with no data
            // revert(offset, size) — size 0 means no error message returned
            revert(0x00, 0x00)


            // FUNCTION: updateHorseNumber(uint256 newNumberOfHorses)
            // reads the uint256 argument from calldata and stores it in slot 0
            function updateHorseNumber() {

                // calldata layout for this function:
                // bytes 0-3:   function selector (0xcdfead2e)
                // bytes 4-35:  first argument (newNumberOfHorses) as uint256

                // calldataload(4) loads 32 bytes starting at byte 4
                // this skips the 4-byte selector and reads our uint256 argument
                let newNumberOfHorses := calldataload(4)

                // sstore(slot, value) writes value to persistent storage at slot
                // slot 0 = numberOfHorses
                // this is exactly what Solidity compiles numberOfHorses = newValue to
                sstore(0x00, newNumberOfHorses)

                // stop() ends execution cleanly with no return data
                // equivalent to STOP opcode
                stop()
            }


            // FUNCTION: readNumberOfHorses() returns (uint256)
            // reads slot 0 from storage and returns it as ABI encoded uint256
            function readNumberOfHorses() {

                // sload(slot) reads 32 bytes from persistent storage at slot
                // slot 0 = numberOfHorses
                // pushes the stored value onto the stack
                let numberOfHorses := sload(0x00)

                // to return a value we must ABI encode it into memory first
                // ABI encoding for a single uint256 is just the 32-byte value itself
                // mstore(offset, value) writes 32 bytes to memory at offset
                // we use memory offset 0x00 as scratch space
                mstore(0x00, numberOfHorses)

                // return(memoryOffset, byteLength)
                // returns 32 bytes from memory offset 0x00 to the caller
                // the caller reads this as the uint256 return value
                return(0x00, 0x20)
            }
        }
    }
}

