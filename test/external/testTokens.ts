// Native
import * as fs from "fs";
import { exec, execSync } from "child_process";
import { promisify } from "util";
import pLimit from "p-limit";

const execAsync = promisify(exec);

// Limit concurrency of task spawning
const limit = pLimit(3);

// Function cache
const functionCacheFile = "functionCache.json";
const functionCache = JSON.parse(fs.readFileSync(functionCacheFile, "utf8"));

const main = (functionSelector0x: string, amountOfTokens: string, tokenNamesCsv: string) => {
  // Split the token names into an array, using comma delimiter
  const tokenNames = tokenNamesCsv.split(",");
  tokenNames.pop();

  // Check that the number of tokens matches the number of token names
  if (tokenNames.length !== parseInt(amountOfTokens)) {
    console.error("Error: The number of tokens does not match the number of token names");
    process.exit(1);
  }

  // Parse additional input
  const amountOfTokensNum = Number(amountOfTokens.slice(2));
  const functionSelector = functionSelector0x.slice(2).replace(/0+$/, "");

  // Search for the human-readable function name from the foundry out/ ABI
  let functionName = functionCache[functionSelector];

  if (!functionName) {
    functionName = execSync(
      `grep -r "${functionSelector}" out | grep "test" | cut -d: -f2 | cut -d\\" -f2 | cut -d\\( -f1`
    )
      .toString()
      .trim();

    functionCache[functionSelector] = functionName;
    fs.writeFileSync(functionCacheFile, JSON.stringify(functionCache, null, 2));
  }

  const reportFile = "reports/TOKENS_REPORT.md";

  // Create a writable stream to the report file
  const writeStream = fs.createWriteStream(reportFile, { flags: "a" });

  // If the file was just created, write the header row
  fs.stat(reportFile, (err, stats) => {
    if (err || !stats.size) {
      writeStream.write("| TestName | TokenName | Result |\n| -------- | --------- | ------ |\n")
    }
  });

  // Create task list
  const tasks: Promise<any>[] = [];

  // Use a for loop based on range 1..$AMOUNT_OF_TOKENS
  for (let i = 1; i <= amountOfTokensNum; i++) {
    tasks.push(
      limit(() =>
        execAsync(`FORGE_TOKEN_TESTER_ID=${i} forge test --mt "${functionName}" --silent --ffi`)
      )
    );
  }

  // Run all tasks asynchronously
  Promise.allSettled(tasks).then((results) => {
    results.forEach((result, i) =>
      result.status === "fulfilled"
        ? writeStream.write(`| ${functionName} | ${tokenNames[i]} | ✅ |\n`)
        : writeStream.write(`| ${functionName} | ${tokenNames[i]} | ❌ |\n`)
    );

    // End the stream to ensure all data is flushed to the file
    writeStream.end();
  });
};

const args = process.argv.slice(2);

if (args.length != 3) {
  console.error(`Error: Please supply the correct parameters.`);
  process.exit(1);
}

main(args[0], args[1], args[2]);

// NOTE: Testing command
// node dist/testTokens.js "0x7258935200000000000000000000000000000000000000000000000000000000" "0x01" "BaseERC20,"
