require "./time_block"
require "./mio_kuji"
# スプレッドシートに送信する場合は以下4行とsend_dataメソッド内のコメントアウトを外す
# require "google_drive"
# session = GoogleDrive::Session.from_config("config.json")
# sp = session.spreadsheet_by_url("スプレッドシートのURL")  # スプレッドシートのURL
# ws = sp.worksheet_by_title("シート1") # シート名
ws = nil  # spreadsheet使用時はこの行は削除する

def set_up
  data = []
  num = 0
  while num < 9 do
    data << TimeBlock.new(num + 13)
    num += 1
  end
  mio = MioKuji.new
  return data, mio
end

def send_data(ws, tb, time)
  # row = time.day + 125        # 行と日付を合わせる場合 time.day
  # column = time.hour - 8      # A列から詰めて書く場合  time.hour - 12
  # ws[row, column] = "#{tb.get_maximum_staying}"
  # ws.save
  tb.sent
  puts "Spreadsheet updated!\n\n"
end

# メイン画面
time_blocks, mio = set_up
line = "------------------------------"
while true
  puts line
  puts "数字を入力"
  puts "[1] ひとり来校"
  puts "[2] ひとり帰宅"
  puts "[3] リストを表示"
  puts "[4] 現在の時間帯の情報を送信"
  puts "[5] リセット"
  puts line
  
  input = gets.to_i
  puts line
  time = Time.now
  hour = time.hour

  if (13..21).include?(hour)
    tb = time_blocks[hour - 13]
    next_tb = time_blocks[hour - 12] if hour < 21
    pre_tb = time_blocks[hour - 14] if hour > 13

    # 前の時間帯が未送信の場合は自動送信
    unless pre_tb.nil?
      unless pre_tb.send?
        send_data(ws, pre_tb, time)
        pre_tb.sent
        puts "\n#{hour - 1}時台の最多人数を「#{pre_tb.get_maximum_staying}」で送信しました。\n\n"
      end
    end
  else
    case input
    when 5
      time_blocks, mio = set_up
      puts "リセットしました"
    when 0
      mio.yamane
    when 777
      puts "お試しモードです"
      puts line
      mio.yamane_come_on!
      puts "きみもEnter連打で山根さんに会おう！"
    else
      puts "お疲れ様です。時間外です。\n\n"
    end
    next
  end

  case input
    when 1
      tb.come_one
      next_tb.set_staying(tb.get_staying) unless next_tb.nil?
      send_data(ws, tb, time) if tb.update?
      puts time
    when 2
      tb.leave_one
      next_tb.set_staying(tb.get_staying) unless next_tb.nil?
      send_data(ws, tb, time) unless tb.send?
      puts time
    when 3
      puts "時間帯ごとの最多人数："
      time_blocks.each {|tb| tb.get_maximum_view}
      come_sum = 0
      time_blocks.each {|tb| come_sum += tb.get_coming}
      puts "\n本日の来校者数：#{come_sum}人"
    when 4
      send_data(ws, tb, time)
      puts "\n#{hour}時台の最多人数を「#{tb.get_maximum_staying}」で送信しました。\n\n"
    when 5
      time_blocks, mio = set_up
      puts "リセットしました"
      pre_tb = time_blocks[hour - 14] if hour > 13
      pre_tb.sent unless pre_tb.nil?
    when 0
      mio.yamane
    when 777
      puts "お試しモードです"
      puts line
      mio.yamane_come_on!
      puts "きみもEnter連打で山根さんに会おう！"
    else
      puts "無効な値です"
  end
end