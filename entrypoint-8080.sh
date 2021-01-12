#!/bin/bash

ENTRYPOINT_VERSION="1.0"

ENTRYPOINT_COMMAND=${@:-  12 rails server -b 0.0.0.0 -p 8080 }

# sourceing ENV variables..
source .env

echo "Command to run: '$ENTRYPOINT_COMMAND'" | lolcat
# if root, if docker, ... you ned to dof this
rake assets:precompile

# We like ENV in docker!
echo "Occasional Message: $(printenv MESSAGGIO_OCCASIONALE | lolcat)"

# And finally...
rails server -b 0.0.0.0 -p 8080


# as a tru docker entrypoint, we should i
"$@"
