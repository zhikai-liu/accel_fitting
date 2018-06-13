function coeff=coeff_delta_signal(data,kernel,timepoint)

    %% This function is solving an equation: M*x=b
    k_l=length(kernel);
    t_l=length(timepoint);
    ij_lookup=zeros(k_l,1); 
    %% First calculate a lookup sheet for matrix M
    for i=1:k_l % here, i-1 is the difference between ij for later
        %ij_lookup(1) means delta_ij is zero, ij_lookup(k_l) means delta_ij is k_l-1;
        ij_lookup(i)=kernel(1:k_l-i+1)'*kernel(i:k_l);
    end
    %% Fill M with value based on the lookup sheet
    M=zeros(t_l);
    for i=1:t_l
        for j=1:t_l
            if abs(timepoint(i)-timepoint(j))<k_l
            M(i,j)=ij_lookup(abs(timepoint(i)-timepoint(j))+1);
            end
        end
    end
    %% Calculate the vector B
    B=zeros(t_l,1);
    for i=1:length(B)
        if timepoint(i)+k_l<=length(data)
            B(i)=data(timepoint(i)+1:timepoint(i)+k_l)'*kernel;
        else
            B(i)=data(timepoint(i)+1:end)'*kernel(1:length(data)-timepoint(i));
        end
    end   
    coeff=M\B;
end