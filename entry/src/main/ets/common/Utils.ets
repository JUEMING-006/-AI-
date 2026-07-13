// 工具函数集合

// 日期格式化：将 Date 对象格式化为 'YYYY-MM-DD' 字符串
export function formatDate(date: Date): string {
  const year: number = date.getFullYear();
  const month: number = date.getMonth() + 1;
  const day: number = date.getDate();
  const monthStr: string = month < 10 ? `0${month}` : `${month}`;
  const dayStr: string = day < 10 ? `0${day}` : `${day}`;
  return `${year}-${monthStr}-${dayStr}`;
}

// 计算从 today 到 targetDate（'YYYY-MM-DD'）的倒计时天数
// 若目标日期已过，返回 0
export function getDaysCountdown(targetDate: string): number {
  const target: Date = new Date(targetDate);
  const today: Date = new Date();
  today.setHours(0, 0, 0, 0);
  target.setHours(0, 0, 0, 0);
  const diffMs: number = target.getTime() - today.getTime();
  const diffDays: number = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
  return diffDays > 0 ? diffDays : 0;
}

// 格式化倒计时显示文本
export function formatCountdown(targetDate: string): string {
  const days: number = getDaysCountdown(targetDate);
  if (days === 0) {
    return '考试已结束';
  }
  return `距离考试还有 ${days} 天`;
}

// 将数字格式化为两位字符串（如 5 → '05'）
export function padTwoDigits(num: number): string {
  return num < 10 ? `0${num}` : `${num}`;
}

// 获取当前时间戳（秒）
export function getCurrentTimestamp(): number {
  return Math.floor(Date.now() / 1000);
}

// 防抖函数
let debounceTimer: number = -1;
export function debounce(fn: () => void, delay: number): void {
  if (debounceTimer !== -1) {
    clearTimeout(debounceTimer);
  }
  debounceTimer = setTimeout(() => {
    fn();
    debounceTimer = -1;
  }, delay);
}
