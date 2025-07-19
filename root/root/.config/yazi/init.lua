require("full-border"):setup()
require("starship"):setup()
require("git"):setup()
require("simple-mtpfs"):setup({
  mount_point = os.getenv("HOME") .. ("/Android"),
})
