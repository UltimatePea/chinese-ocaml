import json
import html
import re
from datetime import datetime

# 📄 input & output files
INPUT_LOG = "claude.log"
OUTPUT_HTML = "transcript.html"

# Generate timestamp
timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# 📝 start writing the HTML
html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Claude Chat Transcript</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css" rel="stylesheet">
<style>
body {{
  background-color: #f8f9fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}}

.chat-container {{
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}}

.message {{
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}}

.message-header {{
  font-size: 0.85rem;
  color: #6c757d;
  margin-bottom: 5px;
  font-weight: 500;
}}

.message-bubble {{
  padding: 15px 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  position: relative;
}}

.user-message .message-bubble {{
  background: linear-gradient(135deg, #e3f2fd, #bbdefb);
  color: #1565c0;
  border: 1px solid #90caf9;
  margin-left: auto;
  max-width: 80%;
}}

.assistant-message .message-bubble {{
  background: white;
  border: 1px solid #e9ecef;
  margin-right: auto;
  max-width: 85%;
}}

.tool-use {{
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 12px;
  margin: 10px 0;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.9rem;
}}

.tool-use-header {{
  font-weight: bold;
  color: #495057;
  margin-bottom: 8px;
  font-size: 0.95rem;
}}

.tool-result {{
  background: #f1f3f4;
  border-left: 4px solid #28a745;
  padding: 12px;
  margin: 10px 0;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.9rem;
  white-space: pre-wrap;
  word-wrap: break-word;
  max-height: 400px;
  overflow-y: auto;
}}

.thinking {{
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  border-radius: 8px;
  padding: 12px;
  margin: 10px 0;
  font-style: italic;
  color: #856404;
  word-wrap: break-word;
}}

.usage-stats {{
  background: #e7f3ff;
  border: 1px solid #b3d9ff;
  border-radius: 6px;
  padding: 8px 12px;
  margin: 8px 0;
  font-size: 0.8rem;
  color: #0056b3;
}}

pre {{
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  padding: 12px;
  white-space: pre-wrap;
  word-wrap: break-word;
  margin: 10px 0;
  max-height: 300px;
  overflow-y: auto;
}}

code {{
  background: #f8f9fa;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.9em;
}}

.timestamp {{
  font-size: 0.75rem;
  color: #adb5bd;
  margin-top: 5px;
}}

.session-divider {{
  border-top: 2px solid #dee2e6;
  margin: 30px 0;
  text-align: center;
  position: relative;
}}

.session-divider::after {{
  content: "New Session";
  background: #f8f9fa;
  padding: 5px 15px;
  color: #6c757d;
  font-size: 0.8rem;
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%);
}}
</style>
</head>
<body>
<div class="container-fluid">
  <div class="chat-container">
    <div class="text-center mb-4">
      <h1 class="display-4">Claude Chat Transcript</h1>
      <p class="text-muted">Generated on {timestamp}</p>
    </div>
    <div class="messages">
"""

def extract_text_content(content_parts):
    """Extract and format text content from message parts"""
    texts = []
    tool_uses = []
    tool_results = []
    thinking_parts = []
    
    for part in content_parts:
        if isinstance(part, dict):
            if part.get("type") == "text":
                text = part.get("text", "").strip()
                if text:
                    texts.append(text)
            elif part.get("type") == "tool_use":
                tool_name = part.get("name", "Unknown")
                tool_input = part.get("input", {})
                
                # Create a cleaner tool use display
                tool_display = f"🔧 {tool_name}"
                if tool_input:
                    # Format key parameters nicely instead of raw JSON
                    key_params = []
                    for key, value in tool_input.items():
                        if isinstance(value, str) and len(value) > 100:
                            key_params.append(f"{key}: {value[:100]}...")
                        else:
                            key_params.append(f"{key}: {value}")
                    if key_params:
                        tool_display += "\n" + "\n".join(key_params)
                
                tool_uses.append(tool_display)
            elif part.get("type") == "tool_result":
                content = part.get("content", "")
                if isinstance(content, str) and content.strip():
                    tool_results.append(content)
            elif part.get("type") == "thinking":
                thinking = part.get("thinking", "").strip()
                if thinking:
                    thinking_parts.append(thinking)
        elif isinstance(part, str):
            text = part.strip()
            if text:
                texts.append(text)
    
    return texts, tool_uses, tool_results, thinking_parts

def extract_usage_stats(message):
    """Extract token usage statistics from message"""
    usage = message.get("usage", {})
    if not usage:
        return None
    
    stats = []
    if "input_tokens" in usage:
        stats.append(f"Input: {usage['input_tokens']}")
    if "output_tokens" in usage:
        stats.append(f"Output: {usage['output_tokens']}")
    if "cache_creation_input_tokens" in usage:
        stats.append(f"Cache Creation: {usage['cache_creation_input_tokens']}")
    if "cache_read_input_tokens" in usage:
        stats.append(f"Cache Read: {usage['cache_read_input_tokens']}")
    
    return " | ".join(stats) if stats else None

def format_content(text):
    """Format content with basic markdown-like formatting"""
    # Escape HTML
    text = html.escape(text)
    
    # Convert code blocks
    text = re.sub(r'```(\w+)?\n(.*?)\n```', r'<pre><code class="language-\1">\2</code></pre>', text, flags=re.DOTALL)
    
    # Convert inline code
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    
    # Convert bold
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    
    # Convert newlines
    text = text.replace('\n', '<br>')
    
    return text

current_session = None
message_count = 0
sections = []
current_section = {"messages": [], "title": "Conversation 1", "start_message": 1}
section_count = 0
total_stats = {
    "total_messages": 0,
    "total_cost": 0.0,
    "total_input_tokens": 0,
    "total_output_tokens": 0,
    "total_cache_tokens": 0,
    "sessions": set()
}

with open(INPUT_LOG, "r", encoding="utf-8") as f:
    for line_num, line in enumerate(f, 1):
        line = line.strip()
        if not line.startswith("{"):
            continue
            
        try:
            obj = json.loads(line)
            
            # Check for conversation result (end of conversation)
            if obj.get("type") == "result":
                # Finish current section
                if current_section["messages"]:
                    current_section["end_message"] = message_count
                    # Calculate actual turns for this section (count user messages)
                    section_turns = len([m for m in current_section["messages"] if m["role"] == "user"])
                    
                    # Extract section stats from result
                    result_data = obj
                    current_section["stats"] = {
                        "duration_ms": result_data.get("duration_ms", 0),
                        "num_turns": section_turns,  # Use calculated turns for this section
                        "total_cost_usd": result_data.get("total_cost_usd", 0.0),
                        "usage": result_data.get("usage", {}),
                        "session_id": result_data.get("session_id", "unknown")
                    }
                    sections.append(current_section)
                    
                    # Update total stats
                    total_stats["total_cost"] += current_section["stats"]["total_cost_usd"]
                    usage = current_section["stats"]["usage"]
                    total_stats["total_input_tokens"] += usage.get("input_tokens", 0)
                    total_stats["total_output_tokens"] += usage.get("output_tokens", 0)
                    total_stats["total_cache_tokens"] += usage.get("cache_read_input_tokens", 0) + usage.get("cache_creation_input_tokens", 0)
                    total_stats["sessions"].add(current_section["stats"]["session_id"])
                
                # Start new section
                section_count += 1
                current_section = {
                    "messages": [], 
                    "title": f"Conversation {section_count + 1}", 
                    "start_message": message_count + 1
                }
                continue
            
            # Check for new session
            session_id = obj.get("session_id")
            if session_id and session_id != current_session:
                current_session = session_id
            
            if obj.get("type") in ("user", "assistant"):
                message = obj.get("message", {})
                role = message.get("role", obj.get("type", "unknown"))
                content_parts = message.get("content", [])
                
                if not content_parts:
                    continue
                
                texts, tool_uses, tool_results, thinking_parts = extract_text_content(content_parts)
                
                # Skip if no meaningful content
                if not texts and not tool_uses and not tool_results and not thinking_parts:
                    continue
                
                message_count += 1
                total_stats["total_messages"] += 1
                
                # Extract usage statistics
                usage_stats = extract_usage_stats(message)
                
                # Store message data for current section
                message_data = {
                    "role": role,
                    "message_num": message_count,
                    "usage_stats": usage_stats,
                    "thinking_parts": thinking_parts,
                    "texts": texts,
                    "tool_uses": tool_uses,
                    "tool_results": tool_results
                }
                current_section["messages"].append(message_data)
                
        except json.JSONDecodeError as e:
            print(f"Warning: Failed to parse JSON on line {line_num}: {e}")
            continue

# Add final section if it has messages
if current_section["messages"]:
    current_section["end_message"] = message_count
    current_section["stats"] = {
        "duration_ms": 0,
        "num_turns": len([m for m in current_section["messages"] if m["role"] == "user"]),
        "total_cost_usd": 0.0,
        "usage": {},
        "session_id": current_session or "unknown"
    }
    sections.append(current_section)

# Build the final HTML with sections
final_html = html_content

# Add total statistics at the top
final_html += f"""
<div class="alert alert-info mb-4">
  <h4>📊 Total Statistics</h4>
  <div class="row">
    <div class="col-md-3"><strong>Total Messages:</strong> {total_stats["total_messages"]}</div>
    <div class="col-md-3"><strong>Total Cost:</strong> ${total_stats["total_cost"]:.4f}</div>
    <div class="col-md-3"><strong>Input Tokens:</strong> {total_stats["total_input_tokens"]:,}</div>
    <div class="col-md-3"><strong>Output Tokens:</strong> {total_stats["total_output_tokens"]:,}</div>
  </div>
  <div class="row mt-2">
    <div class="col-md-6"><strong>Cache Tokens:</strong> {total_stats["total_cache_tokens"]:,}</div>
    <div class="col-md-6"><strong>Unique Sessions:</strong> {len(total_stats["sessions"])}</div>
  </div>
</div>
"""

# Add table of contents
if len(sections) > 1:
    final_html += '<div class="card mb-4"><div class="card-header"><h4>📚 Table of Contents</h4></div><div class="card-body"><ul class="list-unstyled">'
    for i, section in enumerate(sections):
        stats = section.get("stats", {})
        cost = stats.get("total_cost_usd", 0)
        turns = stats.get("num_turns", 0)
        final_html += f'<li><a href="#section-{i+1}" class="text-decoration-none">'
        final_html += f'{section["title"]} (Messages {section["start_message"]}-{section.get("end_message", "?")})'
        if cost > 0:
            final_html += f' - ${cost:.4f}, {turns} turns'
        final_html += '</a></li>'
    final_html += '</ul></div></div>'

# Generate sections
for i, section in enumerate(sections):
    final_html += f'<div id="section-{i+1}" class="section-divider mb-4">'
    final_html += f'<h2 class="text-primary">{section["title"]}</h2>'
    
    # Add section statistics if available
    stats = section.get("stats", {})
    if any(stats.values()):
        final_html += '<div class="card mb-3"><div class="card-body">'
        final_html += '<h6 class="card-title">Section Statistics</h6>'
        final_html += '<div class="row text-sm">'
        if stats.get("total_cost_usd", 0) > 0:
            final_html += f'<div class="col-md-3"><strong>Cost:</strong> ${stats["total_cost_usd"]:.4f}</div>'
        if stats.get("num_turns", 0) > 0:
            final_html += f'<div class="col-md-3"><strong>Turns:</strong> {stats["num_turns"]}</div>'
        if stats.get("duration_ms", 0) > 0:
            duration_min = stats["duration_ms"] / 60000
            final_html += f'<div class="col-md-3"><strong>Duration:</strong> {duration_min:.1f} min</div>'
        
        usage = stats.get("usage", {})
        if usage:
            final_html += f'<div class="col-md-3"><strong>Input Tokens:</strong> {usage.get("input_tokens", 0):,}</div>'
            final_html += f'</div><div class="row text-sm mt-1">'
            final_html += f'<div class="col-md-3"><strong>Output Tokens:</strong> {usage.get("output_tokens", 0):,}</div>'
            if usage.get("cache_read_input_tokens", 0) > 0:
                final_html += f'<div class="col-md-3"><strong>Cache Read:</strong> {usage["cache_read_input_tokens"]:,}</div>'
            if usage.get("cache_creation_input_tokens", 0) > 0:
                final_html += f'<div class="col-md-3"><strong>Cache Creation:</strong> {usage["cache_creation_input_tokens"]:,}</div>'
        
        final_html += '</div></div></div>'
    
    # Generate messages for this section
    for msg in section["messages"]:
        role = msg["role"]
        message_num = msg["message_num"]
        usage_stats = msg["usage_stats"]
        
        final_html += f'<div class="message {role}-message">\n'
        
        # Message header with stats for assistant
        header_text = f"{role.title()} #{message_num}"
        if usage_stats and role == "assistant":
            header_text += f" | Tokens: {usage_stats}"
        final_html += f'  <div class="message-header">{header_text}</div>\n'
        final_html += f'  <div class="message-bubble">\n'
        
        # Add thinking content for assistant
        if msg["thinking_parts"] and role == "assistant":
            for thinking in msg["thinking_parts"]:
                final_html += f'    <div class="thinking">💭 {format_content(thinking)}</div>\n'
        
        # Add main text content
        if msg["texts"]:
            for text in msg["texts"]:
                final_html += f'    <div>{format_content(text)}</div>\n'
        
        # Add tool uses with cleaner formatting
        if msg["tool_uses"]:
            for tool_use in msg["tool_uses"]:
                final_html += f'    <div class="tool-use">{format_content(tool_use)}</div>\n'
        
        # Add tool results
        if msg["tool_results"]:
            for result in msg["tool_results"]:
                final_html += f'    <div class="tool-result">{html.escape(result)}</div>\n'
        
        final_html += f'  </div>\n'
        final_html += f'</div>\n\n'
    
    final_html += '</div>'

# Close HTML
final_html += """
    </div>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-core.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
</body>
</html>
"""

with open(OUTPUT_HTML, "w", encoding="utf-8") as out:
    out.write(final_html)

print(f"✅ Chat transcript written to: {OUTPUT_HTML}")
print(f"📊 Processed {total_stats['total_messages']} messages in {len(sections)} sections")
print(f"💰 Total cost: ${total_stats['total_cost']:.4f}")
print(f"🔢 Total tokens: {total_stats['total_input_tokens'] + total_stats['total_output_tokens']:,} (input: {total_stats['total_input_tokens']:,}, output: {total_stats['total_output_tokens']:,})")
