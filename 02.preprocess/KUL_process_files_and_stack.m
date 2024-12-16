clear
clc
input_folder = 'E:\Dataset_Audio_EEG\AAD_Datasets\AAD_KUL\';

final_result = process_files_and_stack(input_folder);
function final_matrix = process_files_and_stack(input_folder)
    % 获取文件夹中所有 .mat 文件的文件名
    matFiles = dir(fullfile(input_folder, 'S*.mat'));
    
    % 提取文件名中的数值部分并排序
    fileNums = arrayfun(@(x) str2double(regexp(x.name, '\d+', 'match', 'once')), matFiles);
    [~, sortedIdx] = sort(fileNums);
    sortedFiles = matFiles(sortedIdx);
    
    % 初始化 final_matrix 变量，用于存储最终结果
    num_files = length(sortedFiles);
    final_matrix = zeros(num_files, 4624);  % 假设每个文件生成 4624 个数据点

    % 遍历排序后的 .mat 文件
    for i = 1:num_files
        mat_file_path = fullfile(input_folder, sortedFiles(i).name);
        % 获取每个文件的完整标签序列
        track_sequence = get_final_track_sequence(mat_file_path);
        
        % 确保 track_sequence 是一行数据，并保存到 final_matrix 的第 i 行
        final_matrix(i, :) = track_sequence;
        
        % 显示处理进度
        fprintf('Processed %s\n', sortedFiles(i).name);
    end
end

function final_result = get_final_track_sequence(mat_file_path)
    data = load(mat_file_path, 'trials');
    trials = data.trials;
    
    final_result = [];  % 初始化空数组用于存储结果

    for i = 1:length(trials)
        % 获取当前 trial 的 get_track_value 返回值
        track_value = get_track_value_for_trial(trials{1, i});
        
        % 获取当前 trial 的 EegData 长度（秒数）
        eeg_data = trials{1, i}.RawData.EegData;
        num_samples = size(eeg_data, 1);  % 采样点数
        duration_in_seconds = num_samples / 128;  % 采样率为 128 Hz
        
        % 将 track_value 复制 duration_in_seconds 次
        repeated_values = repmat(track_value, 1, duration_in_seconds);
        
        % 将结果连接到最终的结果数组中
        final_result = [final_result, repeated_values];
    end
    
    % 如果结果不是 4624 长度，则调整其长度
    if length(final_result) > 4624
        final_result = final_result(1:4624);  % 截断到 4624 长度
    elseif length(final_result) < 4624
        final_result = [final_result, nan(1, 4624 - length(final_result))];  % 用 NaN 填充至 4624 长度
    end
end

function track_value = get_track_value_for_trial(trial)
    attended_track = trial.attended_track;
    stimuli = trial.stimuli;
    
    if attended_track == 1
        if contains(stimuli{1, 1}, 'track1')
            track_value = 1;
        elseif contains(stimuli{2, 1}, 'track1')
            track_value = 2;
        else
            track_value = nan; % 默认值，如果没有匹配
        end
    elseif attended_track == 2
        if contains(stimuli{1, 1}, 'track2')
            track_value = 1;
        elseif contains(stimuli{2, 1}, 'track2')
            track_value = 2;
        else
            track_value = nan; % 默认值，如果没有匹配
        end
    else
        track_value = nan; % 默认值，如果没有匹配
    end
end
