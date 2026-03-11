// SPDX-License-Identifier: GPL-3.0-only

object "HorseStore" {

    // runs once at deployment, copies runtime code and returns it
    code {
        datacopy(0x00, dataoffset("HorseStore_runtime"), datasize("HorseStore_runtime"))
        return(0x00, datasize("HorseStore_runtime"))
    }

    object "HorseStore_runtime" {
        code {
            // numberOfHorses lives at storage slot 0
            // read first 4 bytes of calldata to get function selector
            let selector := shr(224, calldataload(0))

            // updateHorseNumber(uint256) => 0xcdfead2e
            if eq(selector, 0xcdfead2e) {
                // arg starts at byte 4 (after selector)
                sstore(0x00, calldataload(4))
                stop()
            }

            // readNumberOfHorses() => 0xe026c017
            if eq(selector, 0xe026c017) {
                // load slot 0, write to memory, return 32 bytes
                mstore(0x00, sload(0x00))
                return(0x00, 0x20)
            }

            // no match, revert with no data
            revert(0x00, 0x00)
        }
    }
}

