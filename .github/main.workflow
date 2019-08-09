workflow "Pull request" {
  resolves = ["GitHub Action for npm"]
  on = "pull_request"
  runs-on = "macOS-10.14"
}
action "Checkout"{
  uses = actions/checkout@ci
}

action "Setup Node.js for use with actions" {
  uses = "actions/setup-node@v9.11.2"
}

action "GitHub Action for npm" {
  uses = "actions/npm@latest"
  needs = ["Setup Node.js for use with actions"]
  runs = "npm install"
  args = "--global npm@latest"
}
action "Bootstrap"{
  needs = ["Github Action for npm"]
  runs = "./bootstrap.sh"
}
