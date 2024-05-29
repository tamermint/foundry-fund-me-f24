# Foundry Fund-Me Follow along with Pat Collins Cyfrin Updraft

- Changes to be posted here

- forge test command has a new alias for testing a specific test case:

```zsh
forge test --m testPriceFeedVersion -vvvvv --fork-url $SEPOLIA_RPC_URL
error: unexpected argument '--m' found

  tip: a similar argument exists: '--mp'
```

- `--m` is deprecated and replaced with `--mp or --mt` for specifying a specific test case :

```zsh
forge test --mt testPriceFeedVersion -vvvvv --fork-url $SEPOLIA_RPC_URL
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/FundMeTest.t.sol:FundMeTest
[PASS] testPriceFeedVersion() (gas: 16944)
Traces:
  [409026] FundMeTest::setUp()
    ├─ [371246] → new FundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← [Return] 1854 bytes of code
    └─ ← [Stop]

  [16944] FundMeTest::testPriceFeedVersion()
    ├─ [8815] FundMe::getVersion() [staticcall]
    │   ├─ [5753] 0x694AA1769357215DE4FAC081bf1f309aDC325306::version() [staticcall]
    │   │   ├─ [398] 0x719E22E3D4b690E5d96cCb40619180B5427F14AE::version() [staticcall]
    │   │   │   └─ ← [Return] 4
    │   │   └─ ← [Return] 4
    │   └─ ← [Return] 4
    ├─ [0] VM::assertEq(4, 4) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 3.47s (895.69ms CPU time)
```
