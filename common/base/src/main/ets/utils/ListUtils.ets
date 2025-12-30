
/**
 * 列表线条
 */
export class ListDividerBorder {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 0
  color: ResourceColor = $r('app.color.border_color')

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    strokeWidth && (this.strokeWidth = strokeWidth)
    this.startMargin = startMargin
    this.endMargin = endMargin
    color && (this.color = color)
  }
}