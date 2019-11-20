const Compute = require("@google-cloud/compute");
import yargs = require("yargs");

enum Command {
  status,
  start,
  stop
}

yargs
  .command(
    ["status", "$0"],
    "Tells you the status of the instance",
    () => {},
    async argv => await run(Command.status, argv)
  )
  .command(
    "start",
    "Starts the instance",
    () => {},
    async argv => await run(Command.start, argv)
  )
  .command(
    "stop",
    "Stops the instance",
    () => {},
    async argv => await run(Command.stop, argv)
  )
  .option("zone", {
    alias: "z",
    description: "The zone (eg. us-west2-b) in which your instance was created",
    type: "string"
  })
  .option("instance", {
    alias: "i",
    description: "The instance name (eg. myinstance)",
    type: "string"
  })
  .help()
  .alias("help", "h").argv;

async function run(command: Command, argv: yargs.Arguments) {
  if (!argv.zone) {
    console.log("Please provide the zone");
    process.exit(1);
  }

  if (!argv.instance) {
    console.log("Please provide the instance name");
    process.exit(1);
  }

  const compute = new Compute();
  const vm = compute.zone(argv.zone).vm(argv.instance);

  if (!vm) {
    console.log("VM not found");
    process.exit(1);
  }

  switch (command) {
    case Command.status:
      const getRes = await vm.get();
      if (!getRes[0]) {
        return;
      }

      console.log(getRes[0].metadata.status);
      break;
    case Command.start:
      const startRes = await vm.start();
      console.log(startRes[0].metadata.status);

      break;
    case Command.stop:
      const stopRes = await vm.stop();
      console.log(stopRes[0].metadata.status);

      break;
  }
}
