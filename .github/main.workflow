workflow "New workflow" {
  on = "pull_request"
  resolves = ["GitHub Action for npm"]
}

action "Checkout" {
  uses = "actions/checkout@master"
}

action "Setup Node.js for use with actions" {
  uses = "actions/setup-node@v1"
  needs = ["Checkout"]
  args = "version = 9.11.2"
}

action "GitHub Action for npm" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["Setup Node.js for use with actions"]
}
