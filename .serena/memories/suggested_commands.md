# Suggested Commands

## Development Commands

### Install Dependencies
```bash
yarn install
```

### Build All Packages
```bash
yarn build
```

### Development Mode (Watch)
```bash
yarn dev
```

### Run Tests
```bash
yarn test
```

### Lint Code
```bash
yarn lint
yarn lint:fix  # Auto-fix issues
```

### Clean Build Artifacts
```bash
yarn clean
```

## Package-Specific Commands

### MCP Server Only
```bash
yarn workspace @claude-code/mcp-server build
yarn workspace @claude-code/mcp-server dev
yarn workspace @claude-code/mcp-server test
yarn workspace @claude-code/mcp-server start
```

## System Commands (Darwin/macOS)
```bash
# Git
git status
git diff
git add .
git commit -m "message"

# File operations
ls -la
find . -name "*.ts"
grep -r "pattern" .

# Directory navigation
cd packages/mcp-server
pwd
```

## Running the MCP Server
```bash
# Build first
yarn build

# Run directly
node packages/mcp-server/dist/index.js

# Or via package script
yarn workspace @claude-code/mcp-server start
```
