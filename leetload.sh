if [ -z $1 ]; then
  echo "Please specify either a problem id or \"today\" for today's problem"
  exit 1
fi

# check dependencies
if [ -z $(npm -v 2>/dev/null) ]; then
  echo "npm could not be found. Please ensure it is installed and discoverable"
fi

read -p "Please enter the root directory: " dirpath

if [ ! -d "$dirpath" ]; then
  echo "Directory $dirpath does not exist."
  exit 1
fi

QID=""
QSLUG=""
LEETCODEQL_URL='https://leetcode.com/graphql'

if [ "$1" = "today" ]; then
  PROBLEM_CONTENT=$(curl -s $LEETCODEQL_URL \
    -H "Content-Type: application/json" \
    -d '{ "query": "query questionOfToday { activeDailyCodingChallengeQuestion { question { questionFrontendId, titleSlug } } }" }')
  QSLUG=$(echo "$PROBLEM_CONTENT" | jq -r '.data.activeDailyCodingChallengeQuestion.question.titleSlug')
  QID=$(echo "$PROBLEM_CONTENT" | jq -r '.data.activeDailyCodingChallengeQuestion.question.questionFrontendId')
else
  echo "Not yet implemented."
  exit 1
fi

# titleSlug is what we will need for subsequent fetches
if [ -z $QSLUG ]; then
  echo "failed to retrieve question $1"
  exit 1
fi

# see if the problem has already been initialized
PROBLEM_DIR="$dirpath/leetcode-$QID"

if [ -d $PROBLEM_DIR ]; then
  echo "Problem $QID has already been setup at $dirpath"
  exit 1
fi

# Setup the folder
echo "Setting up at $PROBLEM_DIR"
mkdir $PROBLEM_DIR
cd $PROBLEM_DIR
npm init -y -f
echo "Installing Dependencies"
npm i -D typescript ts-node
tsc --init
echo "/node_modules/" >.gitignore
touch index.ts

# Fetch the problem content
content=$(curl -s 'https://leetcode.com/graphql' \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query questionContent($titleSlug: String!) { question(titleSlug: $titleSlug) { content } }",
    "variables": { "titleSlug": '"$QSLUG"' }
  }' \
  | tr '\n\t' ' ' \
  | jq -r '.data.question.content')

echo "# #$QID: $QSLUG" >PROBLEM.md
echo >>PROBLEM.md
echo "## Problem:" >>PROBLEM.md
echo $content >>PROBLEM.md
