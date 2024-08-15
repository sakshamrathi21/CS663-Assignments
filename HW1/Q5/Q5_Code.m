clear; clc;

J1 = double(imread('T1.jpg'));
J2 = double(imread('T2.jpg'));
J3 = imrotate(J2, 28.5, 'crop');
%% (a) part
imwrite(J3, 'T2_rotated.jpg');

%% (b) part
angles = -45:1:45;
NCC = zeros(1,length(angles));
JE = zeros(1,length(angles));
QMI = zeros(1,length(angles));
bin_width = 10;

for i = 1:length(angles)
    J4 = imrotate(J3+1, angles(i), 'crop');
    [J1_masked, J4_masked] = get_valid_pixels(J1, J4);
    NCC(i) = get_NCC(J1_masked, J4_masked);
    norm_joint_hist = get_norm_joint_hist(J1_masked, J4_masked, bin_width);
    JE(i) = get_JE(norm_joint_hist);
    QMI(i) = get_QMI(norm_joint_hist);
end

function [J1_masked, J2_masked] = get_valid_pixels(J1, J2)
    J2 = J2 - 1;
    valid_mask = J2 ~= -1; % Unoccupied points have -1 in them, remove them from calculations
    J1_masked = J1(valid_mask);
    J2_masked = J2(valid_mask);
end

function NCC = get_NCC(A,B)
    A_mean = mean(A,'all');
    B_mean = mean(B,'all');
    num = sum((A-A_mean).*(B-B_mean),'all');
    den = sqrt(sum((A-A_mean).^2,'all')*sum((B-B_mean).^2,'all'));
    NCC = abs(num/den);
end

function joint_hist = get_joint_hist(image1, image2, bin_width)
    num_bins = round(255 / bin_width);
    joint_hist = zeros(num_bins, num_bins);
    for x = 1:size(image1, 1)
        for y = 1:size(image1, 2)
            bin_image1 = floor(image1(x, y) / bin_width) + 1;
            bin_image2 = floor(image2(x, y) / bin_width) + 1;
            joint_hist(bin_image1, bin_image2) = joint_hist(bin_image1, bin_image2) + 1;
        end
    end
end

function norm_joint_hist = get_norm_joint_hist(image1, image2, bin_width)
    joint_hist = get_joint_hist(image1, image2, bin_width);
    norm_joint_hist = joint_hist / sum(joint_hist(:));
end

function JE = get_JE(norm_joint_hist)
    non_zero_mask = norm_joint_hist ~= 0; % Don't take points where it is zero, otherwise log2 function causes error
    JE = -1*(sum(norm_joint_hist(non_zero_mask).*log2(norm_joint_hist(non_zero_mask)),'all'));
end

function QMI = get_QMI(norm_joint_hist)
    num_bins = size(norm_joint_hist, 1);
    hist_image1 = zeros(num_bins, 1);
    hist_image2 = zeros(num_bins, 1);
    for x = 1:num_bins
        for y = 1:num_bins
            hist_image1(x) = hist_image1(x) + norm_joint_hist(x, y);
            hist_image2(y) = hist_image2(y) + norm_joint_hist(x, y);
        end
    end
    norm_hist_image1 = hist_image1 / sum(hist_image1);
    norm_hist_image2 = hist_image2 / sum(hist_image2);
    QMI = 0;
    for x = 1:num_bins
        for y = 1:num_bins
            QMI = QMI + (norm_joint_hist(x, y) - norm_hist_image1(x) * norm_hist_image2(y))^2;
        end
    end
end

%% (c) part
figure(1);
plot(angles, NCC);
xlabel('theta'); ylabel('NCC');
title('Normalised Cross Correlation'); grid on;
saveas(gcf,'NCC.png');

figure(2);
plot(angles, JE);
xlabel('theta');
ylabel('JE');
title('Joint Entropy'); grid on;
saveas(gcf,'JE.png');

figure(3);
plot(angles, QMI);
xlabel('theta');
ylabel('QMI');
title('Quadratic Mutual Information'); grid on;
saveas(gcf,'QMI.png');

%% (e) part
[min_JE, index] = min(JE);
optimal_theta_JE = angles(index);
J4 = imrotate(J3+1, optimal_theta_JE, 'crop');
[J1_masked, J4_masked] = get_valid_pixels(J1, J4);
joint_hist = get_joint_hist(J1_masked, J4_masked, bin_width);

figure(4);
imagesc(0:bin_width:255, 0:bin_width:255, joint_hist); colorbar;
xlabel('J4'); ylabel('J1');
title('Joint Histogram for minimum JE with bin width 10');
saveas(gcf,'Joint_hist_JE.png');