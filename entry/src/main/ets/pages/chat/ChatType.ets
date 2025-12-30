
// 会话数据模型
export  class ChatSession {
  id: string
  title: string
  timestamp: string

  constructor(id: string, title: string, timestamp: string) {
    this.id = id
    this.title = title
    this.timestamp = timestamp
  }
}

