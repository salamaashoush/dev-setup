export function main(): void {
  console.log('Hello from PROJECT_NAME! 🚀');
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}