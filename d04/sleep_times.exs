defmodule Guards do
  def accumulate_sleep_times(unsorted_log) do
    sorted_log = Enum.sort(unsorted_log)
    do_accumulate_sleep_times(sorted_log, %{})
  end

  def do_accumulate_sleep_times([], time_map), do: time_map

  def do_accumulate_sleep_times([h|t], time_map) do
    l = parse_single_log(h)
    do_process_single_log(l.action, l, t, time_map, nil, nil)
  end

  def do_process_single_log("begins", l, [h|t], time_map, _, _) do
    new_log = parse_single_log(h)
    do_process_single_log(new_log.action, new_log, t, time_map, l.guard, nil)
  end

  def do_process_single_log("falls", l, [h|t], time_map, g, _) do
    new_log = parse_single_log(h)
    do_process_single_log(new_log.action, new_log, t, time_map, g, l.minute)
  end

  def do_process_single_log("wakes", l, [], time_map, g, start) do
    # IO.puts("Guard #{g} waking @ #{l.minute}")
    if Map.has_key?(time_map, g) do
      Map.put(time_map, g, time_map[g] + l.minute - start)
    else
      Map.put_new(time_map, g, l.minute - start)
    end
  end

  def do_process_single_log("wakes", l, [h|t], time_map, g, start) do
    new_log = parse_single_log(h)
    do_process_single_log(new_log.action, new_log, t, do_process_single_log("wakes", l, [], time_map, g, start), g, nil)
  end

  def do_extract_match_as_int(nil), do: nil
  def do_extract_match_as_int(match_list) do
    String.to_integer(hd(match_list))
  end

  def extract_regex_as_integer(r, s) do
    do_extract_match_as_int(Regex.run(r, s, capture: :all_but_first))
  end

  def do_extract_match(nil, _), do: nil
  def do_extract_match(match_list, index), do: Enum.at(match_list, index)

  def extract_regex_as_string(r, s, index \\ 0) do
    do_extract_match(Regex.run(r, s, capture: :all_but_first), index)
  end

  def parse_single_log(log_entry) do
    %{
      :date => extract_regex_as_string(~r/^\[(\d+-\d{2}-\d{2}) /, log_entry),
      :minute => extract_regex_as_integer(~r/\d{2}:(\d{2})]/, log_entry),
      :guard => extract_regex_as_integer(~r/Guard #(\d+)/, log_entry),
      :action => extract_regex_as_string(~r/\] (Guard #\d+ )?(\w+) /, log_entry, 1),
    }
  end

  def find_sleepiest_minute(unsorted_log, guard) do
    sorted_log = Enum.sort(unsorted_log)
    minute_map = do_find_sleepiest_minute(sorted_log, guard, %{})
    IO.inspect hd(Enum.sort_by(minute_map, &(-elem(&1, 1))))
    {minute, _} = hd(Enum.sort_by(minute_map, &(-elem(&1, 1))))
    minute
  end

  def do_find_sleepiest_minute([h|t], g, minute_map) do
    l = parse_single_log(h)
    do_process_sleepy(l.action, l, t, g, minute_map, nil, nil)
  end

  def do_process_sleepy("begins", l, [h|t], g, minute_map, _, _) do
    new_log = parse_single_log(h)
    do_process_sleepy(new_log.action, new_log, t, g, minute_map, l.guard, nil)
  end

  def do_process_sleepy("falls", l, [h|t], g, minute_map, current, _) do
    new_log = parse_single_log(h)
    do_process_sleepy(new_log.action, new_log, t, g, minute_map, current, l.minute)
  end

  def do_process_sleepy("wakes", l, [], g, minute_map, current, start) do
    if g == current or g == nil do
      # IO.puts("Recording minutes for #{current} @ #{start} to #{l.minute}")
      record_minutes(minute_map, current, start, l.minute-1)
    else
      minute_map
    end
  end

  def do_process_sleepy("wakes", l, [h|t], g, minute_map, current, start) do
    new_log = parse_single_log(h)
    do_process_sleepy(new_log.action, new_log, t, g, do_process_sleepy("wakes", l, [], g, minute_map, current, start), current, nil)
  end

  def record_minutes(minute_map, g, start_time, end_time) do
    do_record_minutes(minute_map, g, Enum.to_list(start_time..end_time))
  end

  def do_record_minutes(minute_map, _, []), do: minute_map

  def do_record_minutes(minute_map, g, [h|t]) do
    if Map.has_key?(minute_map, {g, h}) do
      # IO.puts("  Bumping {#{g}-#{h}} to #{minute_map[{g,h}] + 1}")
      do_record_minutes(Map.put(minute_map, {g, h}, minute_map[{g,h}] + 1), g, t)
    else
      do_record_minutes(Map.put_new(minute_map, {g, h}, 1), g, t)
    end
  end
end



guard_log = [
  "[1518-11-01 00:00] Guard #10 begins shift",
  "[1518-11-01 00:05] falls asleep",
  "[1518-11-01 00:25] wakes up",
  "[1518-11-01 00:30] falls asleep",
  "[1518-11-01 00:55] wakes up",
  "[1518-11-01 23:58] Guard #99 begins shift",
  "[1518-11-02 00:40] falls asleep",
  "[1518-11-02 00:50] wakes up",
  "[1518-11-03 00:05] Guard #10 begins shift",
  "[1518-11-03 00:24] falls asleep",
  "[1518-11-03 00:29] wakes up",
  "[1518-11-04 00:02] Guard #99 begins shift",
  "[1518-11-04 00:36] falls asleep",
  "[1518-11-04 00:46] wakes up",
  "[1518-11-05 00:03] Guard #99 begins shift",
  "[1518-11-05 00:45] falls asleep",
  "[1518-11-05 00:55] wakes up",
]

guard_log =
  File.stream!("guard_log.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.to_list

sleep_time_map = Guards.accumulate_sleep_times(guard_log)


sorted = Enum.sort_by(sleep_time_map, &(-elem(&1, 1)))
IO.inspect sorted
{sleepiest_guard, _} = Enum.at(sorted,0)
IO.puts("Sleepiest Guard is #{sleepiest_guard}")
# minute = Guards.find_sleepiest_minute(guard_log, sleepiest_guard)
{_, minute} = Guards.find_sleepiest_minute(guard_log, sleepiest_guard)
IO.puts("Final answer is: #{sleepiest_guard * minute}")
overall = Guards.find_sleepiest_minute(guard_log, nil)
IO.inspect overall
{guard, minute} = overall
IO.puts("Sleepiest minute answer is: #{guard * minute}")