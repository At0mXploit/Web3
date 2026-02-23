// SPDX-License-Identifier: MIT

// app.dedaub.com
pragma solidity ^0.8.20;

// EVM = Ethereum Virtual Machine
// Stack based machine, 256-bit word size (32 bytes)
// Every operation is an opcode that costs gas

contract EVMOpcodeBreakdown {

    // slot 0 in persistent storage
    // SSTORE writes to it, SLOAD reads from it
    uint256 public storedNumber;

    // slot 1
    // CALLER opcode pushes msg.sender onto stack
    address public owner;

    // slot 2
    // ISZERO opcode used when checking bool conditions
    bool public flag;

    // PUSH1 ... PUSH32 — push 1 to 32 bytes onto the stack
    // POP              — remove top item from stack
    // DUP1 ... DUP16  — duplicate nth stack item
    // SWAP1 ... SWAP16 — swap top of stack with nth item

    constructor() {
        // CALLER — pushes msg.sender onto stack
        // PUSH1 0x01 — pushes slot number 1
        // SSTORE — pops key and value, writes to storage
        owner = msg.sender;

        // PUSH1 0x2a — pushes 42 onto stack
        // PUSH1 0x00 — pushes slot 0
        // SSTORE — writes 42 into slot 0
        storedNumber = 42;
    }


    // ARITHMETIC OPCODES

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        // ADD — pops two values from stack, pushes their sum
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        // SUB — pops two values, pushes a - b
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        // MUL — pops two values, pushes their product
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        // DIV — pops two values, pushes a / b (integer division)
        // if b == 0 the result is 0, no revert (EVM default behavior)
        return a / b;
    }

    function modulo(uint256 a, uint256 b) public pure returns (uint256) {
        // MOD — pops two values, pushes a % b
        return a % b;
    }

    function exponent(uint256 base, uint256 exp) public pure returns (uint256) {
        // EXP — pops base and exponent, pushes result
        // gas cost is 10 + 50 per byte in the exponent (can be expensive)
        return base ** exp;
    }

    function addMod(uint256 a, uint256 b, uint256 mod) public pure returns (uint256) {
        // ADDMOD — pops a, b, N — pushes (a + b) % N without intermediate overflow
        return addmod(a, b, mod);
    }

    function mulMod(uint256 a, uint256 b, uint256 mod) public pure returns (uint256) {
        // MULMOD — pops a, b, N — pushes (a * b) % N without intermediate overflow
        return mulmod(a, b, mod);
    }


    // COMPARISON OPCODES

    function compare(uint256 a, uint256 b) public pure returns (bool lt, bool gt, bool eq) {
        // LT — pops two values, pushes 1 if a < b else 0
        lt = a < b;

        // GT — pops two values, pushes 1 if a > b else 0
        gt = a > b;

        // EQ — pops two values, pushes 1 if a == b else 0
        eq = a == b;
    }

    function isZeroCheck(uint256 a) public pure returns (bool) {
        // ISZERO — pops one value, pushes 1 if it is zero else 0
        return a == 0;
    }


    // BITWISE OPCODES

    function bitwiseAnd(uint256 a, uint256 b) public pure returns (uint256) {
        // AND — pops two values, pushes bitwise AND result
        return a & b;
    }

    function bitwiseOr(uint256 a, uint256 b) public pure returns (uint256) {
        // OR — pops two values, pushes bitwise OR result
        return a | b;
    }

    function bitwiseXor(uint256 a, uint256 b) public pure returns (uint256) {
        // XOR — pops two values, pushes bitwise XOR result
        return a ^ b;
    }

    function bitwiseNot(uint256 a) public pure returns (uint256) {
        // NOT — pops one value, flips every bit, pushes result
        return ~a;
    }

    function shiftLeft(uint256 a, uint256 bits) public pure returns (uint256) {
        // SHL — pops shift amount and value, pushes value << shift
        return a << bits;
    }

    function shiftRight(uint256 a, uint256 bits) public pure returns (uint256) {
        // SHR — pops shift amount and value, pushes value >> shift (logical, unsigned)
        return a >> bits;
    }

    function getByteAt(uint256 val, uint256 index) public pure returns (uint256 result) {
        assembly {
            // BYTE — pops index and value, pushes the single byte at that index
            // index 0 = most significant byte of the 32-byte word
            result := byte(index, val)
        }
    }

    function signExtendExample(uint256 b, uint256 x) public pure returns (uint256 result) {
        assembly {
            // SIGNEXTEND — sign-extends x from (b+1) bytes to 256 bits
            // used internally when casting smaller signed integers
            result := signextend(b, x)
        }
    }


    // STORAGE OPCODES

    function readStorage() public view returns (uint256) {
        // PUSH1 0x00 — push slot number 0
        // SLOAD — pops slot number, pushes value stored at that slot
        // costs 2100 gas cold, 100 gas warm (EIP-2929)
        return storedNumber;
    }

    function writeStorage(uint256 newVal) public {
        // PUSH newVal onto stack
        // PUSH1 0x00 — slot 0
        // SSTORE — writes newVal into slot 0
        // costs 20000 gas for a new (zero to nonzero) value
        // costs 2900 gas to update an existing nonzero value
        storedNumber = newVal;
    }


    // MEMORY OPCODES
    // Memory is temporary, only lives during the current call, much cheaper than storage

    function memoryExample(uint256 val) public pure returns (uint256 result) {
        assembly {
            // MSTORE — pops offset and value, writes 32 bytes to memory at offset
            mstore(0x00, val)

            // MLOAD — pops offset, reads 32 bytes from memory, pushes value
            result := mload(0x00)

            // MSIZE — pushes current allocated memory size in bytes
        }
    }


    // CALLDATA OPCODES
    // calldata is the read-only input data sent with the transaction, very cheap

    function calldataExample() public pure returns (bytes4 sig) {
        assembly {
            // CALLDATALOAD — pops offset, pushes 32 bytes of calldata starting there
            // CALLDATASIZE — pushes total byte length of calldata
            // CALLDATACOPY — copies a chunk of calldata into memory
            sig := calldataload(0) // first 4 bytes = function selector
        }
    }


    // HASHING

    function hashExample(uint256 a) public pure returns (bytes32) {
        // SHA3 (KECCAK256) — pops memory offset and length, pushes 32-byte hash
        // base cost 30 gas + 6 gas per 32-byte word of input
        return keccak256(abi.encode(a));
    }


    // CONTROL FLOW OPCODES

    function controlFlow(uint256 x) public pure returns (uint256) {
        // JUMPDEST — marks a valid jump destination in bytecode
        // JUMPI    — pops destination and condition, jumps if condition != 0
        // JUMP     — pops destination, unconditional jump
        // PC       — pushes the current program counter value
        if (x > 10) {
            // compiler inserts JUMPI here to skip this block when x <= 10
            return x * 2;
        }
        return x + 1;
    }

    function requireExample(uint256 x) public pure returns (uint256) {
        // if condition is false: push error string to memory then REVERT
        // if condition is true: JUMPI skips over the revert block
        require(x > 0, "must be > 0");
        return x;
    }

    function revertExample(uint256 x) public pure {
        if (x == 0) {
            // REVERT — pops memory offset and length, returns error data to caller
            // rolls back all state changes and refunds remaining gas
            revert("x is zero");
        }
    }

    function stopExample() public pure returns (uint256) {
        // RETURN — pops memory offset and length, returns data, ends execution
        // STOP   — ends execution with no return data (zero gas cost)
        return 1;
    }


    // ENVIRONMENT / BLOCK OPCODES

    function envOpcodes() public view returns (
        address caller,
        uint256 value,
        uint256 gasLeft,
        uint256 blockNum,
        uint256 timestamp,
        uint256 chainid
    ) {
        // CALLER    — pushes address of the direct caller (msg.sender)
        caller = msg.sender;

        // CALLVALUE — pushes amount of ETH sent with this call in wei
        value = msg.value;

        // GAS       — pushes remaining gas at the point this opcode executes
        gasLeft = gasleft();

        // NUMBER    — pushes current block number
        blockNum = block.number;

        // TIMESTAMP — pushes current block unix timestamp in seconds
        timestamp = block.timestamp;

        // CHAINID   — pushes chain ID (1 = mainnet, 11155111 = sepolia)
        chainid = block.chainid;
    }

    function getOrigin() public view returns (address) {
        // ORIGIN — pushes tx.origin, the original EOA that signed the transaction
        // different from CALLER when called through a contract
        return tx.origin;
    }

    function getGasPrice() public view returns (uint256) {
        // GASPRICE — pushes gas price of current transaction in wei per gas unit
        return tx.gasprice;
    }

    function getCoinbase() public view returns (address) {
        // COINBASE — pushes address of the block's fee recipient (validator)
        return block.coinbase;
    }

    function getGasLimit() public view returns (uint256) {
        // GASLIMIT — pushes the maximum gas allowed in the current block
        return block.gaslimit;
    }

    function getPrevRandao() public view returns (uint256) {
        // PREVRANDAO — pushes beacon chain randomness from the previous block
        // renamed from DIFFICULTY after the Ethereum merge (EIP-4399)
        return block.prevrandao;
    }

    function getBlockHash(uint256 blockNumber) public view returns (bytes32) {
        // BLOCKHASH — pops block number, pushes its hash
        // only works for the last 256 blocks, returns 0 for anything older
        return blockhash(blockNumber);
    }


    // ADDRESS OPCODES

    function addressOpcodes() public view returns (address self, uint256 bal) {
        // ADDRESS — pushes the address of this contract
        self = address(this);

        // BALANCE — pops an address, pushes its ETH balance in wei
        bal = address(this).balance;
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            // EXTCODESIZE — pops address, pushes byte length of its deployed code
            // size > 0 means it is a contract, size == 0 means EOA (or empty contract)
            size := extcodesize(addr)
        }
        return size > 0;
    }


    // CALL OPCODES

    function externalCall(address target) public returns (bool success) {
        // CALL — calls another contract, can send ETH
        // pops: gas, addr, value, argsOffset, argsLength, retOffset, retLength
        // pushes: 1 on success, 0 on failure (does NOT revert automatically)
        (success, ) = target.call{value: 0}("");
    }

    // STATICCALL  — same as CALL but any state change inside reverts automatically (used for view)
    // DELEGATECALL — runs the target's code but in THIS contract's storage context (used by proxies)


    // LOG OPCODES (events)
    // LOG0 — no indexed topics
    // LOG1 — 1 indexed topic
    // LOG2 — 2 indexed topics
    // LOG3 — 3 indexed topics
    // LOG4 — 4 indexed topics (maximum)
    // logs are stored in the transaction receipt, not in state, so they are cheap

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function emitEvent(address to, uint256 amount) public {
        // LOG3 generated here: event sig hash + 2 indexed args = 3 topics
        // pops: data offset, data length, topic1, topic2, topic3
        emit Transfer(msg.sender, to, amount);
    }


    // SELFDESTRUCT

    function destroy(address payable recipient) public {
        require(msg.sender == owner, "not owner");
        // SELFDESTRUCT — sends all contract ETH to recipient, ends execution
        // after EIP-6780 (Cancun upgrade) code is only deleted if called in the same deployment tx
        selfdestruct(recipient);
    }
}

