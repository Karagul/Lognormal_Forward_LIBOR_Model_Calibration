function y = Formula7(a,b,c,d,rho_inf,beta,caplet_vol ,discount)
    
    out = zeros(10,10);
    Phi = zeros(10,1);
    
    for i = 1:10
        
        Ti_1 = i;
        fun = @(t) (((a.*(Ti_1-t) + d).*exp(-b.*(Ti_1-t)) + c).^2);
        denominator = integral(fun,0,Ti_1); 
        vi_mkt = caplet_vol(i) * sqrt(i);
        Phi(i) = sqrt(vi_mkt*vi_mkt/denominator);
        
    end
    
    rho = zeros(10,10);
    for i = 1:10
        for j = 1:10
            rho(i,j) = rho_inf+(1-rho_inf)*exp(-beta*abs(i-j));
            %rho(i,j) = 0.99;
        end    
    end
    
    F = zeros(20,1);
    for i = 1:20
        F(i) = (1/i) * (1/discount(4*i) - 1);
    end
    
    for alpha = 0:9
        for beta = (alpha+1):(alpha+10)   
            w = zeros(beta-alpha,1);
            for i = (alpha+1):beta
                numerator = 1;
                for j = (alpha+1) : i
                    numerator = numerator * (1/(1+F(j)));
                end 
                w(i-alpha) = numerator;
            end
            Sum = sum(w);
            w = w/Sum;    
            
            S_deno = 0;
            for i = (alpha+1):beta
                S_deno = S_deno + discount(4*i);
            end
            
            if alpha == 0
                S = (1 - discount(4*beta))/S_deno;
            else 
                S = (discount(4*alpha) - discount(4*beta))/S_deno;
            end
            
            swaption_vol = 0;
            if beta <= 10
                for i = (alpha+1):beta
                    for j = (alpha+1) : beta
                        coef = w(i-alpha)*w(j-alpha)*F(i)*F(j)*rho(i,j)/((alpha+1)*S*S);

                        this_vol = 0;
                        for h = 0:alpha
                            this_vol = this_vol + Phi(i)*((a*(i-h-1)+d)*exp(-b*(i-h-1))+c)*Phi(j)*((a*(j-h-1)+d)*exp(-b*(j-h-1))+c);
                        end

                        this_vol = this_vol * coef;

                        swaption_vol = swaption_vol + this_vol;
                    end      
                end
            end
            out(alpha+1,beta-alpha) = sqrt(swaption_vol);
        end 
    end

    y = out;
   


    
    
end

