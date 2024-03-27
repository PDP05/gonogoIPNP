function getData(src, ~)
    [data, timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    plot(timestamps,data);
end

