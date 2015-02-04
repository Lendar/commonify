function cleanConsole() {
  console.log('\033[2J');
}

function main() {
  cleanConsole();
  console.log('test run');
}

main();
