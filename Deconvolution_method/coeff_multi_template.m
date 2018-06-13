function coeff=coeff_multi_template(data,kernels,timepoint)

    %% This function is solving a series of equations, here the example is three: 
    %M11*A+M12*B+M13*C=Y1
    %M21*A+M22*B+M23*C=Y2
    %M31*A+M32*B+M33*C=Y3
    
    k_n=size(kernels,2);
    k_l=size(kernels,1);
    t_l=length(timepoint);
    ij_lookup=cell(k_n);
    M=cell(k_n);
    %% First calculate a lookup sheet for matrix M
    for m=1:size(ij_lookup,1)
        for n=1:size(ij_lookup,2)
            ij_lookup{m,n}=zeros(k_l,1); 
            for i=1:k_l % here, i-1 is the difference between ij for later
                %ij_lookup(1) means delta_ij is zero, ij_lookup(k_l) means delta_ij is k_l-1;
                ij_lookup{m,n}(i)=kernels(1:k_l-i+1,m)'*kernels(i:k_l,n);
                % in the lookup sheet, kernel n is always before kernel m
                % on the timeline
            end
        end
    end
    %% Fill M with value based on the lookup sheet
    for m=1:size(M,1)
        for n=1:size(M,2)
             M{m,n}=zeros(t_l);
            for i=1:t_l
                for j=1:t_l
                    if abs(timepoint(i)-timepoint(j))<k_l
                        if timepoint(i)>timepoint(j) %is this larger or smaller?
                            M{m,n}(i,j)=ij_lookup{m,n}(timepoint(i)-timepoint(j)+1);
                        else
                            M{m,n}(i,j)=ij_lookup{n,m}(timepoint(j)-timepoint(i)+1);
                        end
                    end
                end
            end
        end
    end
    %% Calculate the vector Y
    Y=cell(k_n,1);
    for m=1:k_n
        Y{m}=zeros(t_l,1);
        for i=1:t_l
            if timepoint(i)+k_l<=length(data)
                Y{m}(i)=data(timepoint(i)+1:timepoint(i)+k_l)'*kernels(:,m);
            else
                Y{m}(i)=data(timepoint(i)+1:end)'*kernels(1:length(data)-timepoint(i),m);
            end
        end
    end
    %% The series of equations can also be presented as:
    % M11, M12, M13   A   Y1
    %(M21, M22, M23)*(B)=(Y2)
    % M31, M32, M33   C   Y3
    %% in which the question will be simplified as M*X=Y
    M_all=zeros(k_n*t_l);
    for m=1:size(M,1)
        for n=1:size(M,2)
            M_all(t_l*(m-1)+1:t_l*m,t_l*(n-1)+1:t_l*n)=M{m,n};
        end
    end
    Y_all=zeros(k_n*t_l,1);
    for m=1:k_n
        Y_all(t_l*(m-1)+1:t_l*m,1)=Y{m,1};
    end
    coeff=M_all\Y_all;
    coeff=reshape(coeff,t_l,k_n);
end