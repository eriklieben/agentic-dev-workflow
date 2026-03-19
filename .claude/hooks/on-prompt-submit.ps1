# Hook: UserPromptSubmit
# Detects wrap-up intent in user messages and injects wrap-up instructions.
# Exit 0 + stdout text = injected as context to Claude.

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/hook-profile.ps1"
if (-not (Test-HookEnabled "prompt-submit" "minimal,standard,strict")) { exit 0 }

$Input = $input | Out-String
$json = $Input | ConvertFrom-Json
$prompt = if ($json.prompt) { $json.prompt } else { "" }

# Normalize: lowercase, trim whitespace
$promptLower = $prompt.ToLower().Trim()

# Detect wrap-up intent
$wrapUpPhrases = @(
    "bye", "goodbye", "exit", "/exit", "quit", "/quit",
    "done", "done for today", "that's it", "thats it", "i'm done", "im done",
    "wrap up", "wrap-up", "wrapup", "wrap it up",
    "end session", "close session", "session done", "session end",
    "we're done", "were done", "all done", "that's all", "thats all",
    "leaving", "signing off", "logging off", "heading out"
)

if ($wrapUpPhrases -contains $promptLower) {
    @"
[WRAP-UP TRIGGERED] The user is ending the session. Execute the /meta-wrap-up skill now:
1. Review deliverables (git status, changed files)
2. Update today's daily memory (context/memory/{YYYY-MM-DD}.md)
3. Check for documentation gaps (missing ADRs, C4 updates needed)
4. Distill significant learnings to context/MEMORY.md
5. Present a brief session summary
6. Ask if they want to commit before leaving
Do NOT ask if they want to wrap up — they already said so. Just do it.
"@
}

exit 0
