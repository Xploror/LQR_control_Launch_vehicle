%cost function
function K = LQR_cost(pitch_ss, V, draw)
    %% Individual state variable plot
    cvector = {'bo' 'ro' 'go'};

    R_vector = [0.01 1 100];

    l = 1;
    R_vector_drift = R_vector(l);
    Q_matrix_drift = [1 0 1/V; 0 0 0; 1/V 0 1/V^2];
    %Q_matrix_drift = [1 0 1/V^2; 0 0 0; 1/V^2 0 1/V^4];
    [K S e] = lqr(pitch_ss, Q_matrix_drift, R_vector_drift);
    [A_m,B_m,C_m,D_m] = ssdata(pitch_ss);
  
    for i = 1:100000
        eig_val(:,i) = eig(A_m-B_m*K*i/10000);
    end
    
    if draw
        for k=1:3 
            subplot(1,3,k)
            plot(real(eig_val(k,:)),imag(eig_val(k,:)),cvector{k});
            xlabel('real axis');ylabel('imagenary axis');
            xlim([-5,1]);
            ylim([-2,2]);
            grid; 
        end

        subplot(1,3,1)
        title('State variable (theta) poles for 100000 variations for R=5')
        subplot(1,3,2)
        title('State variable (theta rate) poles for 100000 variations for R=5')
        subplot(1,3,3)
        title('State variable (Z-drift rate) poles for 100000 variations for R=5')
        
        hold all;
    end
    
    %% Root locus plot

%     Use this to plot the overall root locus plot for given R matrix value. To
%     do this uncomment below codes and comment upper plots and subplots
%     if plot
%         plot(real(eig_val(1,:)),imag(eig_val(1,:)),cvector{1});
%         hold all;
%         plot(real(eig_val(2,:)),imag(eig_val(2,:)),cvector{1});
%         hold all;
%         plot(real(eig_val(3,:)),imag(eig_val(3,:)),cvector{1});
%         hold all;
%         grid;
%     end
% end