import http from '@ohos.net.http'
import util from '@ohos.util'

interface EventSourceOptions {
  method?: http.RequestMethod
  headers?: Record<string, string>
  body?: string
}

interface EventSourceEvent {
  data: string
  type?: string
}

interface RequestOptions {
  method: http.RequestMethod
  header: Record<string, string>
  readTimeout: number
  extraData?: string
}

type EventCallback = (event: EventSourceEvent) => void

export default class CustomEventSource {
  private httpRequest: http.HttpRequest
  private url: string
  private options: EventSourceOptions
  private onmessage: EventCallback | null = null
  private onerror: ((error: Error) => void) | null = null
  private oncomplete: (() => void) | null = null
  private buffer: string = ''
  private isActive: boolean = false
  private decoder: util.TextDecoder = new util.TextDecoder()

  constructor(url: string, options: EventSourceOptions = {}) {
    this.url = url
    this.options = options
    this.httpRequest = http.createHttp()
    this.connect()
  }

  private connect() {
    this.isActive = true
    const headers: Record<string, string> = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache'
    }
    
    if (this.options.headers) {
      // 合并headers
      headers['Content-Type'] = this.options.headers['Content-Type'] || headers['Content-Type'] || ''
      headers['Accept'] = this.options.headers['Accept'] || headers['Accept'] || ''
      headers['Cache-Control'] = this.options.headers['Cache-Control'] || headers['Cache-Control'] || ''
      headers['Connection'] = this.options.headers['Connection'] || ''
    }

    const requestOptions: RequestOptions = {
      method: this.options.method || http.RequestMethod.GET,
      header: headers,
      readTimeout: 0
    }

    if (this.options.body) {
      requestOptions.extraData = this.options.body
    }

    // 设置数据接收监听
    this.httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      if (!this.isActive) return
      try {
        const chunk = this.decoder.decode(new Uint8Array(data))
        this.processChunk(chunk)
      } catch (e) {
        this.handleError(new Error('Failed to decode chunk'))
      }
    })

    // 发起请求
    let promise = this.httpRequest.requestInStream(
      this.url,
      requestOptions
    )

    promise.then((data: number) => {
      if (this.oncomplete) {
        this.oncomplete()
      }
    }).catch((err: Error) => {
      this.handleError(err)
    });
  }

  private processChunk(chunk: string) {
    this.buffer += chunk
    const lines = this.buffer.split('\n')
    this.buffer = lines[lines.length - 1] || ''

    for (let i = 0; i < lines.length - 1; i++) {
      const line = lines[i]
      if (line.trim() === '') continue
      if (line.startsWith('data:')) {
        const data = line.slice(5).trim()
        if (this.onmessage) {
          try {
            this.onmessage({ data })
          } catch (e) {
            this.handleError(new Error('Error in message handler'))
          }
        }
      }
    }
  }

  private handleError(error: Error) {
    if (this.onerror) {
      this.onerror(error)
    }
    this.close()
  }

  public close() {
    this.isActive = false
    if (this.httpRequest) {
      this.httpRequest.off('dataReceive')
      this.httpRequest.destroy()
    }
  }

  public set onMessage(callback: EventCallback) {
    this.onmessage = callback
  }

  public set onError(callback: (error: Error) => void) {
    this.onerror = callback
  }

  public set onComplete(callback: () => void) {
    this.oncomplete = callback
  }
}
