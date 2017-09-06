function [ A ] = Function_MonteCarloOnSingleLayerTissue( times, theta_i, ua, ut, n0, n1)
    m = 10; thres = 0.0001; pi2=2*%pi;
    delta_x = 0.005;
    A = zeros(depth/delta_z+1,width/delta_x+1);
    photon = struct('x',0,'y',0,'z',0,'ux',0,'uy',0,'uz',1,'w',1,'s',-log(rand()));
    // Start //
    N = 0; theta_t = asin(n0*sin(theta_i)/n1); // Refraction
    Rsp = ((n0*cos(theta_t)-n1*cos(theta_i))/(n0*cos(theta_t)+n1*cos(theta_i))).^2; 
    u = ua / ut; critical = asin(n0/n1);
    fig = 0;
    while(N < times)
        // Launch //
        if(modulo(N+1,10) == 0)
            close(fig);
            fig=waitbar((N+1)/times);
        end
        photon.x = 0; photon.y = 0; photon.z = 0;   // Location
        photon.ux = sin(theta_t); photon.uy = 0; photon.uz = cos(theta_t); // Direction
        ux = photon.ux; uy = photon.uy;
        photon.w = 1 - Rsp;                         // Loss of reflection
        // Travel
        photon.s = -log(rand())/ut;
        photon.x = photon.x + photon.ux*photon.s;
        photon.z = photon.z + photon.uz*photon.s;
        // Absorption
        delta_w = u * photon.w;
        if(photon.z < depth & abs(photon.x) < width/2) // Record (only in the area of 1cm*1cm)
            x = (photon.x + width/2)/delta_x + 1;
            z = photon.z/delta_z + 1;
            a = z - floor(z); b = 1 - a; c = x - floor(x); d = 1 - c;
            temp = delta_w * [b*d b*c; a*d a*c];
            // Bilinear interpolation in x-z plane
            A(floor(z):floor(z)+1,floor(x):floor(x)+1) = A(floor(z):floor(z)+1,floor(x):floor(x)+1) + temp;
        end
        photon.w = photon.w - delta_w;
        // Scattering
        phi = pi2*rand();
        theta = (1.81-(0.19/(0.1+1.8*rand()))^2)/1.8;
        if(abs(photon.uz) > 0.99999)
            photon.ux = sin(acos(theta)) * cos(phi);
            photon.uy = sin(acos(theta)) * sin(phi);
            photon.uz = sign(photon.uz) * theta;
        else
            photon.ux = sin(acos(theta))*(ux*photon.uz*cos(phi)-uy*sin(phi))/sqrt(1-photon.uz^2) + ux*theta;
            photon.uy = sin(acos(theta))*(uy*photon.uz*cos(phi)+ux*sin(phi))/sqrt(1-photon.uz^2) + uy*theta;
            photon.uz = -sin(acos(theta))*cos(phi)*sqrt(1-photon.uz^2) + photon.uz*theta;
        end
        ux = photon.ux; uy = photon.uy;
        // Iteration //
        while(photon.w <> 0)
            // Travel
            photon.s = -log(rand()) / ut;
            photon.x = photon.x + photon.ux*photon.s;
            photon.z = photon.z + photon.uz*photon.s;
            // Boundary crossing determination
            if(photon.z < 0)
                alpha_i = acos(abs(photon.uz));
                if(alpha_i < critical)  // Total reflection
                    /*
                    if(photon.z < -0.99999)
                        photon.w = photon.w * Rsp;
                    else
                        alpha_t = asin(n1*sin(alpha_i)/n0);
                        photon.w = photon.w * ((sin(alpha_i-alpha_t))^2/(sin(alpha_i+alpha_t))^2+(tan(alpha_i-alpha_t))^2/(tan(alpha_i+alpha_t))^2)/2;
                    end
                end
                */
                    photon.z = -photon.z;
                    photon.uz = -photon.uz;
                end
            end
            // Absorption
            delta_w = u * photon.w;
            if(photon.z < depth & abs(photon.x) < width/2) // Record (only in the area of 1cm*1cm)
                x = (photon.x + width/2)/delta_x + 1;
                z = photon.z/delta_z + 1;
                a = z - floor(z); b = 1 - a; c = x - floor(x); d = 1 - c;
                temp = delta_w * [b*d b*c; a*d a*c];
                // Bilinear interpolation in x-z plane
                A(floor(z):floor(z)+1,floor(x):floor(x)+1) = A(floor(z):floor(z)+1,floor(x):floor(x)+1) + temp;
            end
            photon.w = photon.w - delta_w;
            // Scattering
            phi = pi2*rand();
            theta = (1.81-(0.19/(0.1+1.8*rand()))^2)/1.8;
            if(abs(photon.uz) > 0.99999)
                photon.ux = sin(acos(theta)) * cos(phi);
                photon.uy = sin(acos(theta)) * sin(phi);
                photon.uz = sign(photon.uz) * theta;
            else
                photon.ux = sin(acos(theta))*(ux*photon.uz*cos(phi)-uy*sin(phi))/sqrt(1-photon.uz^2) + ux*theta;
                photon.uy = sin(acos(theta))*(uy*photon.uz*cos(phi)+ux*sin(phi))/sqrt(1-photon.uz^2) + uy*theta;
                photon.uz = -sin(acos(theta))*cos(phi)*sqrt(1-photon.uz^2) + photon.uz*theta;
            end
            ux = photon.ux; uy = photon.uy;
            // Russian Roulette
            if(photon.w < thres)
                if(rand() > 1/m)
                    photon.w = 0;
                else
                    photon.w = m * photon.w;
                end
            end
        end
        N = N + 1;
        disp(N);
    end
    close(fig);
endfunction
