import { useState, useRef, useEffect } from "react";

const styles = `
  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: #0f1117;
    color: #e2e8f0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    height: 100vh;
    overflow: hidden;
  }

  #root { height: 100vh; }

  .app {
    display: flex;
    flex-direction: column;
    height: 100vh;
    max-width: 900px;
    margin: 0 auto;
  }

  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 24px;
    border-bottom: 1px solid #1e2433;
    background: #0f1117;
    flex-shrink: 0;
  }

  .header-left { display: flex; align-items: center; gap: 12px; }

  .logo {
    width: 36px; height: 36px;
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px;
  }

  .header h1 { font-size: 18px; font-weight: 600; color: #f1f5f9; }
  .header p { font-size: 12px; color: #64748b; margin-top: 1px; }

  .new-chat-btn {
    background: #1e2433;
    color: #94a3b8;
    border: 1px solid #2d3748;
    border-radius: 8px;
    padding: 7px 14px;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.15s;
  }
  .new-chat-btn:hover { background: #2d3748; color: #e2e8f0; }

  .messages {
    flex: 1;
    overflow-y: auto;
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    scrollbar-width: thin;
    scrollbar-color: #2d3748 transparent;
  }

  .messages::-webkit-scrollbar { width: 6px; }
  .messages::-webkit-scrollbar-track { background: transparent; }
  .messages::-webkit-scrollbar-thumb { background: #2d3748; border-radius: 3px; }

  .empty-state {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 16px;
    color: #475569;
    padding: 40px;
    text-align: center;
  }

  .empty-state .icon { font-size: 48px; opacity: 0.6; }
  .empty-state h2 { font-size: 20px; color: #64748b; font-weight: 500; }
  .empty-state p { font-size: 14px; line-height: 1.6; max-width: 420px; }

  .suggestions {
    display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; margin-top: 8px;
  }

  .suggestion {
    background: #1e2433; border: 1px solid #2d3748;
    border-radius: 20px; padding: 6px 14px;
    font-size: 13px; color: #94a3b8;
    cursor: pointer; transition: all 0.15s;
  }
  .suggestion:hover { background: #2d3748; color: #e2e8f0; border-color: #3b82f6; }

  .message { display: flex; gap: 12px; animation: fadeIn 0.2s ease; }
  .message.user { flex-direction: row-reverse; }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .avatar {
    width: 32px; height: 32px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 14px; flex-shrink: 0; margin-top: 2px;
    font-weight: 600;
  }

  .message.user .avatar { background: linear-gradient(135deg, #3b82f6, #2563eb); color: white; }
  .message.assistant .avatar { background: linear-gradient(135deg, #8b5cf6, #6d28d9); }
  .message.error .avatar { background: #7f1d1d; }

  .bubble {
    max-width: 75%;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .bubble-text {
    padding: 12px 16px;
    border-radius: 16px;
    font-size: 14px;
    line-height: 1.6;
    white-space: pre-wrap;
  }

  .message.user .bubble-text {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: #fff;
    border-bottom-right-radius: 4px;
  }

  .message.assistant .bubble-text {
    background: #1e2433;
    color: #e2e8f0;
    border-bottom-left-radius: 4px;
    border: 1px solid #2d3748;
  }

  .message.error .bubble-text {
    background: #2d1515;
    color: #fca5a5;
    border: 1px solid #7f1d1d;
    border-bottom-left-radius: 4px;
  }

  .sql-block {
    background: #0d1117;
    border: 1px solid #2d3748;
    border-radius: 10px;
    overflow: hidden;
    font-size: 13px;
  }

  .block-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 8px 14px;
    background: #161b22;
    border-bottom: 1px solid #2d3748;
    cursor: pointer;
    user-select: none;
  }

  .block-label { display: flex; align-items: center; gap: 6px; color: #64748b; font-size: 12px; }

  .sql-badge {
    background: #1d4ed8; color: #93c5fd;
    padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 700;
    letter-spacing: 0.05em;
  }

  .row-badge {
    background: #14532d; color: #86efac;
    padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 700;
  }

  .sql-pre {
    padding: 14px;
    overflow-x: auto;
    color: #a5d6ff;
    font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
    line-height: 1.6;
    font-size: 12.5px;
  }

  .table-block {
    background: #0d1117;
    border: 1px solid #2d3748;
    border-radius: 10px;
    overflow: hidden;
  }

  .table-wrap { overflow-x: auto; max-height: 280px; overflow-y: auto; }
  .table-wrap::-webkit-scrollbar { width: 5px; height: 5px; }
  .table-wrap::-webkit-scrollbar-thumb { background: #2d3748; border-radius: 3px; }

  table { width: 100%; border-collapse: collapse; font-size: 13px; }
  thead { position: sticky; top: 0; z-index: 1; }
  th {
    background: #161b22;
    color: #94a3b8;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    padding: 8px 12px;
    text-align: left;
    border-bottom: 1px solid #2d3748;
    white-space: nowrap;
  }
  td {
    padding: 7px 12px;
    border-bottom: 1px solid #1a2030;
    color: #cbd5e1;
  }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #1a2030; }

  .chevron { color: #475569; transition: transform 0.2s; font-size: 10px; }
  .chevron.open { transform: rotate(180deg); }

  .typing {
    display: flex; align-items: center; gap: 12px;
    animation: fadeIn 0.2s ease;
  }

  .typing-avatar {
    width: 32px; height: 32px; border-radius: 50%;
    background: linear-gradient(135deg, #8b5cf6, #6d28d9);
    display: flex; align-items: center; justify-content: center;
    font-size: 14px; flex-shrink: 0;
  }

  .dots { display: flex; gap: 5px; padding: 12px 16px; background: #1e2433; border-radius: 16px; border-bottom-left-radius: 4px; border: 1px solid #2d3748; }
  .dot {
    width: 7px; height: 7px; border-radius: 50%;
    background: #3b82f6;
    animation: bounce 1.2s infinite;
  }
  .dot:nth-child(2) { animation-delay: 0.2s; }
  .dot:nth-child(3) { animation-delay: 0.4s; }

  @keyframes bounce {
    0%, 80%, 100% { transform: translateY(0); opacity: 0.4; }
    40% { transform: translateY(-6px); opacity: 1; }
  }

  .input-area {
    padding: 16px 24px 24px;
    flex-shrink: 0;
    border-top: 1px solid #1e2433;
    background: #0f1117;
  }

  .input-row {
    display: flex; gap: 10px; align-items: flex-end;
    background: #1e2433;
    border: 1px solid #2d3748;
    border-radius: 14px;
    padding: 10px 10px 10px 16px;
    transition: border-color 0.15s;
  }

  .input-row:focus-within { border-color: #3b82f6; }

  textarea {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    color: #e2e8f0;
    font-size: 14px;
    resize: none;
    max-height: 120px;
    line-height: 1.5;
    font-family: inherit;
  }

  textarea::placeholder { color: #475569; }

  .send-btn {
    width: 36px; height: 36px;
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    border: none; border-radius: 10px;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all 0.15s;
    flex-shrink: 0;
  }

  .send-btn:hover:not(:disabled) { opacity: 0.85; transform: scale(1.05); }
  .send-btn:disabled { opacity: 0.35; cursor: not-allowed; transform: none; }

  .send-btn svg { width: 16px; height: 16px; fill: white; }

  .hint { text-align: center; font-size: 11px; color: #334155; margin-top: 8px; }
`;

function CollapsibleSQL({ sql }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="sql-block">
      <div className="block-header" onClick={() => setOpen(!open)}>
        <div className="block-label">
          <span className="sql-badge">SQL</span>
          Generated Query
        </div>
        <span className={`chevron ${open ? "open" : ""}`}>▼</span>
      </div>
      {open && <pre className="sql-pre">{sql}</pre>}
    </div>
  );
}

function CollapsibleTable({ resultSet }) {
  const [open, setOpen] = useState(true);
  const cols = resultSet?.resultSetMetaData?.rowType ?? [];
  const rows = resultSet?.data ?? [];
  const numRows = resultSet?.resultSetMetaData?.numRows ?? rows.length;
  if (!rows.length) return null;

  return (
    <div className="table-block">
      <div className="block-header" onClick={() => setOpen(!open)}>
        <div className="block-label">
          📊 Query Results
          <span className="row-badge">{numRows} rows</span>
        </div>
        <span className={`chevron ${open ? "open" : ""}`}>▼</span>
      </div>
      {open && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>{cols.map((c, i) => <th key={i}>{c.name}</th>)}</tr>
            </thead>
            <tbody>
              {rows.slice(0, 50).map((row, i) => (
                <tr key={i}>{row.map((cell, j) => <td key={j}>{cell ?? "—"}</td>)}</tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

const SUGGESTIONS = [
  "Top 10 customers by revenue",
  "Monthly order trends",
  "Best selling products",
  "Revenue by region",
];

export default function App() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [threadId, setThreadId] = useState(null);
  const [parentMessageId, setParentMessageId] = useState(null);
  const bottomRef = useRef(null);
  const textareaRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  const sendMessage = async (text) => {
    const userMsg = (text || input).trim();
    if (!userMsg || loading) return;

    setInput("");
    if (textareaRef.current) textareaRef.current.style.height = "auto";
    setMessages((prev) => [...prev, { role: "user", text: userMsg }]);
    setLoading(true);

    try {
      const resp = await fetch("http://localhost:8000/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: userMsg,
          thread_id: threadId,
          parent_message_id: parentMessageId,
        }),
      });

      if (!resp.ok) {
        const err = await resp.json().catch(() => ({ detail: resp.statusText }));
        throw new Error(err.detail || `HTTP ${resp.status}`);
      }

      const data = await resp.json();
      setThreadId(data.thread_id);
      setParentMessageId(data.assistant_message_id);

      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          text: data.answer,
          sql: data.sql,
          resultSet: data.result_set,
        },
      ]);
    } catch (err) {
      setMessages((prev) => [
        ...prev,
        { role: "error", text: err.message },
      ]);
    } finally {
      setLoading(false);
      textareaRef.current?.focus();
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const newConversation = () => {
    setMessages([]);
    setThreadId(null);
    setParentMessageId(null);
    textareaRef.current?.focus();
  };

  return (
    <>
      <style>{styles}</style>
      <div className="app">
        <div className="header">
          <div className="header-left">
            <div className="logo">❄</div>
            <div>
              <h1>TPCH Insight Agent</h1>
              <p>Powered by Snowflake Cortex</p>
            </div>
          </div>
          <button className="new-chat-btn" onClick={newConversation}>+ New Chat</button>
        </div>

        <div className="messages">
          {messages.length === 0 && !loading ? (
            <div className="empty-state">
              <div className="icon">❄️</div>
              <h2>Ask anything about your data</h2>
              <p>Query customers, orders, products, and revenue using natural language. The agent will generate and run SQL for you.</p>
              <div className="suggestions">
                {SUGGESTIONS.map((s) => (
                  <button key={s} className="suggestion" onClick={() => sendMessage(s)}>{s}</button>
                ))}
              </div>
            </div>
          ) : (
            messages.map((msg, i) => (
              <div key={i} className={`message ${msg.role}`}>
                <div className="avatar">
                  {msg.role === "user" ? "U" : "❄"}
                </div>
                <div className="bubble">
                  {msg.text && (
                    <div className="bubble-text">
                      {msg.role === "error" && "⚠ "}
                      {msg.text}
                    </div>
                  )}
                  {msg.sql && <CollapsibleSQL sql={msg.sql} />}
                  {msg.resultSet && <CollapsibleTable resultSet={msg.resultSet} />}
                </div>
              </div>
            ))
          )}

          {loading && (
            <div className="typing">
              <div className="typing-avatar">❄</div>
              <div className="dots">
                <div className="dot" />
                <div className="dot" />
                <div className="dot" />
              </div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>

        <div className="input-area">
          <div className="input-row">
            <textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => {
                setInput(e.target.value);
                e.target.style.height = "auto";
                e.target.style.height = e.target.scrollHeight + "px";
              }}
              onKeyDown={handleKeyDown}
              placeholder="Ask about revenue, customers, orders... (Enter to send)"
              rows={1}
              autoFocus
            />
            <button className="send-btn" onClick={() => sendMessage()} disabled={loading || !input.trim()}>
              <svg viewBox="0 0 24 24"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/></svg>
            </button>
          </div>
          <div className="hint">Shift+Enter for new line</div>
        </div>
      </div>
    </>
  );
}
