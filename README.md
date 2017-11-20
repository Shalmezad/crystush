# crystush

[![GitHub release](https://img.shields.io/github/release/Shalmezad/crystush.svg)](https://github.com/Shalmezad/crystush/releases)

Interpreter for the [Push 3 language](http://faculty.hampshire.edu/lspector/push3-description.html) (based on work by Lee Spector, Maarten Keijzer, Jon Klein, Chris Perry and Tom Helmuth, among others)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystush:
    github: shalmezad/crystush
```

## Usage

```crystal
require "crystush"

# Create a string with your program like so:
program_string = "( INTEGER.DUP INTEGER.+ )"

# Create a Crystush Program:
program = Crystush::Program.new(program_string)

# Optional: Create a preloaded stack
preload_stacks = Crystush::PushStacks.new
preload_stacks.integer_stack.push 4

# Evaluate the program:
stacks = program.evaluate(preload_stacks)

# Get the output from any of the stacks:
result = stacks.integer_stack.last
```

## Contributing

1. Fork it ( https://github.com/Shalmezad/crystush/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Shalmezad](https://github.com/Shalmezad) Richard Wardin - creator, maintainer
