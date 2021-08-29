# スプレッドシートに送信する場合は以下4行とsend_dataメソッド内のコメントアウトを外す
# require "google_drive"
# session = GoogleDrive::Session.from_config("config.json")
# sp = session.spreadsheet_by_url("スプレッドシートのURL")  # スプレッドシートのURL
# ws = sp.worksheet_by_title("シート1") # シート名
ws = nil  # 上記コード使用時はコメントアウトする

# メソッド一覧
# 配列の初期化
def set_results  
    results =[]
    9.times do
        results << {come: 0, come_max: 0, come_sum: 0, leave: 0, leave_sum: 0, count: 0}
    end
    results
end
# 現在時刻の確認
def change_time_to_index(time)  
    t = 13
    if 12 < t && t < 22
        index = t - 13
    else
        puts "お疲れ様です。時間外です。"
        index = nil
    end
    index
end
# 最大人数の確認
def confirm_come_max_value(result)  
    result[:come_max] = result[:come] if result[:come_max] < result[:come]
    result[:come_max]
end
# 現在の滞在者数を返す
def update_next_come_value(result)
    result[:come] - result[:leave_sum] + result[:come_sum]
end
# スプレッドシートに最大人数を送信
def send_data(ws, result, time)
    # row = time.day           # 行と日付を合わせる（1日は1行目、2日は2行目...）
    # column = time.hour - 12  # A列から詰める（13時台はA列、14時台はB列...）
    # ws[row, column] = "#{result[:come_max]}"
    # ws.save
    puts "Spreadsheet updated!\n\n"
end
# 送信済みかどうか確認
def first_time?(result)
    if result[:count] == 0
        result[:count] = 1
        return true
    else
        return false
    end
end
# 結果表示
def result_view(result, time)
    t = time.hour
    puts "#{t}時台の暫定最多人数：#{result[:come_max]}人"
    puts "#{t}時台の来校者：#{result[:come_sum]}人"
    puts "#{t}時台の帰宅者：#{result[:leave_sum]}人"
    puts "現在学習中の受講生：#{result[:come] - result[:leave_sum] + result[:come_sum]}人\n\n"
end
# 一人入室
def come_one(results, index, ws, time)
    result = results[index]
    first_time?(result)
    result[:come_max] = confirm_come_max_value(result)
    unless result[:leave] > 0
        result[:come_max] += 1
        result[:come_sum] += 1
        send_data(ws, result, time)
    else
        result[:leave] -= 1
        result[:come_sum] += 1
    end
    results[index + 1][:come] = update_next_come_value(result) unless index == 8
    puts "こんにちは\n\n"
    result_view(result, time)
end
# 一人退室
def leave_one(results, index, ws, time)
    result = results[index]
    result[:come_max] = confirm_come_max_value(result)
    if people_exist?(results)
        result[:leave] += 1
        result[:leave_sum] += 1
        results[index + 1][:come] = update_next_come_value(result) unless index == 8
        puts "お疲れ様でした\n\n"
    else
        puts "誰もいない・・・・・・\n\n"
    end
    send_data(ws, result, time) if first_time?(result)
    result_view(result, time)
end
# 現在の滞在者の有無を確認
def people_exist?(results)
    come = results.sum {|hash| hash[:come_sum]}
    left = results.sum {|hash| hash[:leave_sum]}
    if come > left
        return true
    else
        return false
    end
end
# 途中経過の表示
def show_list(results)
    puts "時間帯ごとの最多人数："
    results.each_with_index do |result,i|
        puts "#{i + 13}時台：#{result[:come_max]}"
    end
    come_sum_sum = 0
    results.each do |result|
        come_sum_sum += result[:come_sum]
    end
    puts "\n本日の来校者数：#{come_sum_sum}人"
end
# 現在の結果を送信
def send_present_data(results, index, ws, time)
    result = results[index]
    first_time?(result)
    result[:come_max] = confirm_come_max_value(results[index])
    send_data(ws, result, time)
    puts "\n#{time.hour}時台の最多人数を「#{result[:come_max]}」で送信しました。\n\n"
    results[index + 1][:come] = update_next_come_value(result) unless index == 8
end
# 一つ前の時間の結果を送信済みか確認。未送信の場合は送信する
def check_last_transmit(results, index, ws, time)
    result = results[index - 1]
    if first_time?(result)
        result[:come_max] = confirm_come_max_value(result)
        row = time.day + 125
        column = time.hour - 9
        ws[row, column] = "#{result[:come_max]}"
        ws.save
        puts "Spreadsheet updated!\n\n"
        results[index][:come] = update_next_come_value(result)
    end
end



push = 0
appear = 0
line = "------------------------------"
time = Time.now
results = set_results
index = change_time_to_index(time)
results[index - 1][:count] = 1 unless index == 0 || index.nil?
puts time



# メイン画面
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
    
    case input
    when 1
    index = change_time_to_index(time)
    unless index.nil?
        check_last_transmit(results, index, ws, time) unless index == 0
        come_one(results, index, ws, time)
    end
    puts time
    
    when 2
    index = change_time_to_index(time)
    unless index.nil?
        check_last_transmit(results, index, ws, time) unless index == 0
        leave_one(results, index, ws, time)
    end
    puts time
    
    when 3
    index = change_time_to_index(time)
    unless index.nil?
        check_last_transmit(results, index, ws, time) unless index == 0
    end
    show_list(results)
    puts ""
    puts time
    
    when 4
    index = change_time_to_index(time)
    unless index.nil?
        check_last_transmit(results, index, ws, time) unless index == 0
        send_present_data(results, index, ws, time)
    end
    puts time
    
    when 5
    results = set_results
    index = change_time_to_index(time)
    results[index - 1][:count] = 1 unless index == 0 || index.nil?
    push = 0
    appear = 0
    puts "リセットしました。"
    puts time
    
    # 確認用
    when 1115
    puts results
    puts time
    
    # 以下、全てオマケ（作：三尾さん）
    when 7
    puts "現在のpush回数：#{push}"
    puts "現在の山根さん遭遇回数：#{appear}"
    
    when 77
    push = 0
    appear = 0
    puts "push回数、appear回数をリセットしました。"
    
    when 777
    puts "お試しモードです"
    puts line
    sleep 0.3
    puts "や"
    sleep 0.5
    puts "ま"
    sleep 0.5
    puts "ね"
    sleep 0.5
    puts "が"
    sleep 1.0
    puts "キタ━━━━(ﾟ∀ﾟ)━━━━!!"
    sleep 1.5
    puts "きみもEnter連打で山根さんに会おう！"

    when 0
    push = push + 1
    random = rand(200)+1
        case random
        when 1..100
            puts "どうも、counting.rbです。\nこのプログラムは戍井さんの提供でお送りしております。"
        when 101..140
            puts "どうも、counting.rbです。\n無効な入力はしないでね!\n絶対にしないでね！"
        when 136..180
            puts "どうも、counting.rbです。\n1~5のコマンドを押してね！\nそれ以外は押さないでね!\n絶対に押さないでね！"
        when 181..198
            puts "100分の1の確率で激レア演出!?\n絶対に見逃すな！"
            puts "現在の出現回数は#{push}push中#{appear}回！！"
        when 199,200
            appear = appear + 1
            sleep 0.3
            puts "や"
            sleep 0.5
            puts "ま"
            sleep 0.5
            puts "ね"
            sleep 0.5
            puts "が"
            sleep 1.0
            puts "キタ━━━━(ﾟ∀ﾟ)━━━━!!"
            sleep 1.5
            puts "おめでとう！"
            puts "現在の山根さん遭遇数は#{appear}回だよ！"
        end
    else
        puts "無効な値です\n\n"
    end
end
