# Source from ~/.zshrc. Starts a ticket session on Sonnet, so every turn stays
# there; a skill's `model:` alone lasts only for the turn that invoked it.
ship() { claude --model sonnet "/ship $1"; }
