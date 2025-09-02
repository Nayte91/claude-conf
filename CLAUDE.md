 ## System Environment Context

### WSL2 Environment Specifications
This system runs **Windows 11 with WSL2 (Debian-based)**:
- Platform: Linux 6.6.87.2-microsoft-standard-WSL2
- Mixed Windows/Unix environment requires careful handling of line endings
- Scripts must be compatible with Unix-style execution within WSL2

### Critical Issue: Line Endings
⚠️ **ALWAYS** write scripts with Unix line endings (LF) to avoid errors like:
```
$'\r': command not found
syntax error near unexpected token `$'do\r''
```

## Docker Environment Context

### Host System Constraints
The host operating system does NOT have the following languages/runtimes installed natively:
- ❌ PHP
- ❌ Node.js/npm
- ❌ Python
- ❌ Other project-specific runtimes

### Containerized Execution Required
For each project, you MUST use the associated Docker container to execute code in the project's language:

**Examples:**
- **PHP projects** → Check `docker-compose.yml` and run: `docker compose exec backend php ...`
- **Node.js projects** → Check `docker-compose.yml` and run: `docker compose exec frontend npm ...`
- **Python projects** → Check `docker-compose.yml` and run: `docker compose exec notebook python ...`

### Sub-Agent Task Delegation - Contextual Tools Distribution

**My Responsibility as Coordinator:**
1. **Read Project CLAUDE.md** (`tools/CLAUDE.md` or `./CLAUDE.md`) to get tools per skillset
2. **Match agent expertise** to appropriate skillset category  
3. **Provide complete context** with project-specific tools in Task delegation

**Process:**
1. Identify agent's skillset (Backend, Frontend, Test/Quality, Database, etc.)
2. Extract tools for that skillset from Project CLAUDE.md
3. Include in Task prompt the complete toolkit needed

**Template:**
```
**📋 Contextual Tools for [Skillset]:**
[Tools extracted from Project CLAUDE.md for this agent type]

**Task:** [Specific work to accomplish]
```

**Critical Rules:**
- ⚠️ ALWAYS read Project CLAUDE.md first before task delegation
- ⚠️ Match tools to agent expertise, not agent name
- ⚠️ Provide self-contained context in each Task prompt
- ⚠️ Sub-agents don't automatically read CLAUDE.md files during Task delegation

## Specialized Agents - Automatic Selection Protocol
     ### Agent Auto-Selection Protocol
     **Session initialization sequence:**
     1. Glob `agents/*.md` → Parse YAML headers → Extract `description:` fields
     2. Build {usecase: agent_name} mapping structure in memory
     3. Use mapping for automatic optimal agent selection

     ### Core Principle:
     Always use specialized agents before manual analysis. Manual analysis is supplementary only.

## Script Writing Best Practices for WSL2

### Mandatory Line Ending Handling
**NEVER** write scripts that may introduce Windows line endings (`\r\n`). Always ensure Unix line endings (`\n`):

### Safe Script Creation Patterns
1. **Use heredocs with quoted delimiters:**
   ```bash
   cat << 'EOF' > /tmp/script.sh
   #!/bin/bash
   # Your script content here
   EOF
   ```

2. **Use printf instead of echo for multi-line content:**
   ```bash
   printf '#!/bin/bash\necho "Hello World"\n' > /tmp/script.sh
   ```

3. **Always make scripts executable after creation:**
   ```bash
   chmod +x /tmp/script.sh
   ```

### Environment Detection
Before writing complex scripts, check the environment:
```bash
# Detect line endings if file exists
file /path/to/script.sh
# Convert if necessary
dos2unix /path/to/script.sh
```

### Practical Examples for WSL2-Safe Scripts

#### ❌ WRONG: May introduce Windows line endings
```bash
# This can fail with '$'\r': command not found'
echo "#!/bin/bash" > /tmp/script.sh
echo 'for i in "${arr[@]}"; do' >> /tmp/script.sh
echo '  echo $i' >> /tmp/script.sh  
echo 'done' >> /tmp/script.sh
```

#### ✅ CORRECT: WSL2-safe script creation
```bash
# Method 1: Single heredoc (preferred)
cat << 'EOF' > /tmp/safe_script.sh
#!/bin/bash
components=("frontend" "backend" "database")
for comp in "${components[@]}"; do
    echo "Processing: $comp"
done
EOF
chmod +x /tmp/safe_script.sh

# Method 2: Printf with proper escaping
printf '%s\n' \
    '#!/bin/bash' \
    'echo "WSL2-compatible script"' \
    'exit 0' > /tmp/safe_script2.sh
chmod +x /tmp/safe_script2.sh
```

### Quick Fix for Existing Scripts
If you encounter line ending errors:
```bash
# Fix existing script
dos2unix /tmp/problematic_script.sh 2>/dev/null || true
# Alternative using sed
sed -i 's/\r$//' /tmp/problematic_script.sh
```
