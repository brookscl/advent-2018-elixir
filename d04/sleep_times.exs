defmodule Guards do
  def accumulate_sleep_times(unsorted_log) do
    sorted_log = Enum.sort(unsorted_log)
    do_accumulate_sleep_times(sorted_log, %{})
  end

  def do_accumulate_sleep_times([], time_map), do: time_map

  # TODO refactor to pattern match parameters for state validation
  def do_accumulate_sleep_times([h|t], time_map) do
    l = parse_single_log(h)
    do_process_single_log(l.action, l, t, time_map, nil, nil)
  end

  # def do_process_single_log(_, _, [], time_map, _, _), do: time_map

  def do_process_single_log("begins", l, [h|t], time_map, _, _) do
    new_log = parse_single_log(h)
    do_process_single_log(new_log.action, new_log, t, time_map, l.guard, nil)
  end

  def do_process_single_log("falls", l, [h|t], time_map, g, _) do
    new_log = parse_single_log(h)
    do_process_single_log(new_log.action, new_log, t, time_map, g, l.minute)
  end

  def do_process_single_log("wakes", l, [], time_map, g, start) do
    IO.puts("Guard #{g} waking @ #{l.minute}")
    if Map.has_key?(time_map, g) do
      Map.put(time_map, g, time_map[g] + l.minute - start)
    else
      Map.put_new(time_map, g, l.minute - start)
    end
  end

  def do_process_single_log("wakes", l, [h|t], time_map, g, start) do
    new_log = parse_single_log(h)
    IO.puts("Guard #{g} waking @ #{l.minute}")
    if Map.has_key?(time_map, g) do
      do_process_single_log(new_log.action, new_log, t, Map.put(time_map, g, time_map[g] + l.minute - start), g, nil)
    else
      do_process_single_log(new_log.action, new_log, t, Map.put_new(time_map, g, l.minute - start), g, nil)
    end
  end


  def extract_regex_as_integer(r, s) do
    String.to_integer(hd(Regex.run(r, s, capture: :all_but_first)))
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
      :guard => extract_regex_as_string(~r/Guard #(\d+)/, log_entry),
      :action => extract_regex_as_string(~r/\] (Guard #\d+ )?(\w+) /, log_entry, 1),
    }
  end
end



test_log = [
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

sleep_time_map = Guards.accumulate_sleep_times(test_log)

sorted = Enum.sort_by(sleep_time_map, &(-elem(&1, 1)))
{sleepiest_guard, _} = Enum.at(sorted,0)
IO.inspect sleepiest_guard