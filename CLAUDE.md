 ## Specialized Agents - Automatic Selection Protocol
    Subagents located in agents/

     ### Agent Auto-Selection Protocol
     **Session initialization sequence:**
     1. Glob `agents/*.md` → Parse YAML headers → Extract `description:` fields
     2. Build {usecase: agent_name} mapping structure in memory
     3. Use mapping for automatic optimal agent selection

     ### Core Principle:
     Always use specialized agents before manual analysis. Manual analysis is supplementary only.
