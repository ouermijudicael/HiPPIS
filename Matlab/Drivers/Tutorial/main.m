

clear;
close all;
clc;


% Add path to Src and Extras folders
addpath('../../Src/', '../../Extras/')

%---------------------------------------------------------------------------------------------%
% Tutorial showing how to use the 1D, 2D, and 3D DBI and PPI interpolation
%---------------------------------------------------------------------------------------------%

clear;
close all;
clc;

  
  %-- 1D Tutorial -- %
  % This example approximates the 1D function f_1(x) = 0.1 / (0.1 + 25 x^2) using the 
  % DBI and PPI methods.
  n = 17;
  m = 33;
  x = linspace(-1.0, 1.0, n);       % input mesh points
  v = 0.1./(0.1 + 25.0*x.^2);       % input data values
  xout = linspace(-1.0, 1.0, m);    % output points
  vt = 0.1./(0.1 + 25.0*xout.^2);   %
  
  d = 8;                            % target and maximum polynomial degree used for each interval
  interpolation_type = 2;           % 1 for DBI and 2 for PPI
  sten = 1;                         % optional parameter to guide stencil selection 1, 2, and 3
  eps0 = 0.01;                      % optional positive parameter to bound interpolant in PPI
  eps1 = 1.0;                       % optional positive parameter to bound interpolant in PPI

  [vout_apprx, deg] = adaptiveInterpolation1D(x, v, xout, d, interpolation_type, sten, eps0, eps1 ); 
  
  %-- Display approximated results --%
  fprintf('-- 1D example -- \n');
  fprintf('i   \t  xout            v            v_apprx            error \n');
  fprintf('-----------------------------------------------------------------\n')
  for i=1:m
    if(mod(i,2)==0)
     fprintf('%d \t %.4f \t %.4f \t %.4f \t %.2E \n', i, xout(i), vt(i), vout_apprx(i), abs(vt(i)-vout_apprx(i)) );
    end
  end
  fprintf('-----------------------------------------------------------------\n')
  fprintf('The maximum error is   %.2E \n \n \n', max(abs(vt-vout_apprx)) );

  %-- Plot approximated results --%
  figure 
  plot(xout, vt, xout, vout_apprx)
  xlabel('x')
  ylabel('y')
  legend('True', 'Approx.')
  title('Approximation of $$f_{1}(x) = \frac{0.1}{0.1 + 25x^{2}}$$', 'Interpreter', 'Latex')

  %-- 2D Tutorial -- %
  % This example approximates the 1D function f_1(x) = 0.1 / (0.1 + 25 (x^2+y^2)) using the 
  % DBI and PPI methods.
  y = x;                             
  v2D = zeros(n,n);
  for j=1:n
    for i=1:n
      v2D(i,j) = 0.1/(0.1 + 25.0*(x(i)^2 + y(j)^2));  % input data values
    end
  end
  m =33;
  vt2D = zeros(m,m);
  xout = linspace(-1.0, 1.0, m);   % output points
  yout = xout;
  for j=1:m
    for i=1:m 
      vt2D(i,j) = 0.1/(0.1 + 25.0*(xout(i)^2 + yout(j)^2));  % true solution data values
    end
  end
 
  d = 8;                             % target and maximum polynomial degree used for each interval
  interpolation_type = 2;            % 1 for DBI and 2 for PPI
  sten = 1;                          % optional parameter to guide stencil selection 1, 2, and 3
  eps0 = 0.01;                       % optional positive parameter to bound interpolant in PPI
  eps1 = 1.0;                        % optional positive parameter to bound interpolant in PPI

  vout_apprx2D = adaptiveInterpolation2D(x, y, v2D, xout,yout, d, interpolation_type, sten, eps0, eps1 ); 

  %-- Display approximated results
  fprintf('-- 2D example -- \n');
  fprintf('i        j         xout            yout            v            v_apprx            error \n');
  fprintf('-------------------------------------------------------------------------------------------\n')
  for i=1:m
    for j=1:m
      if(mod(i,2)==0 && mod(j,2) ==0 && i==j)
        fprintf('%d \t %d \t %.4f \t %.4f \t %.4f \t %.4f \t %.2E \n', i, j,  xout(i), yout(j), vt2D(i,j), vout_apprx2D(i,j), abs(vt2D(i,j)-vout_apprx2D(i,j)) );
      end
    end
  end
  fprintf('-------------------------------------------------------------------------------------------\n')
  fprintf('The maximum error is   %.2E \n \n \n', max(max(abs(vt2D-vout_apprx2D))) );

 
  %-- Plot approximated results --%
  [xx, yy] = meshgrid(xout, yout);
  figure 
  subplot(1,2,1)
  surf(xx, yy, vt2D)
  xlabel('x')
  ylabel('y')
  zlabel('z')
  title('$$f_{1}(x) = \frac{0.1}{0.1 + 25(x^{2} + y^{2})}$$', 'Interpreter', 'Latex')
  subplot(1,2,2)
  surf(xx, yy, vout_apprx2D)
  xlabel('x')
  ylabel('y')
  zlabel('z')
  title('Approximation of $$f_{1}(x) = \frac{0.1}{0.1 + 25(x^{2}+y^{2})}$$', 'Interpreter', 'Latex')


  %-- 3D Tutorial -- %
  % This example approximates the 1D function f_1(x) = 0.1 / (0.1 + 25 (x^2+y^2+z^2)) using the 
  % DBI and PPI methods.
  y = x;
  z = x;
  v3D = zeros(n,n,n);
  for k=1:n
    for j=1:n
      for i=1:n
        v3D(i,j,k) = 0.1/(0.1 + 25.0*(x(i)^2 + y(j)^2 + z(k)^2));  % input data values
      end
    end
  end
  xout = linspace(-1.0, 1.0, m);     % output points
  yout = xout;
  zout = xout;
  vt3D = zeros(m,m,m);
  for k=1:m
    for j=1:m
      for i=1:m
        vt3D(i,j,k) = 0.1/(0.1 + 25.0*(xout(i)^2 + yout(j)^2 + zout(k)^2));  % input data values
      end
    end
  end
 
  d = 8;                             % target and maximum polynomial degree used for each interval
  interpolation_type = 2;            % 1 for DBI and 2 for PPI
  sten = 1;                          % optional parameter to guide stencil selection 1, 2, and 3
  eps0 = 0.01;                       % optional positive parameter to bound interpolant in PPI
  eps1 = 1.0;                        % optional positive parameter to bound interpolant in PPI

  vout_apprx3D = adaptiveInterpolation3D(x, y, z, v3D, xout, yout, zout, d, interpolation_type, sten, eps0, eps1 ); 
 
  %-- Display approximated results
  fprintf('-- 3D example -- \n');
  fprintf('i        j        k        xout            yout            zout            v            v_apprx             error \n');
  fprintf('-------------------------------------------------------------------------------------------------------------------\n')
  for i=1:m
    for j=1:m
      for k=1:m
        if(mod(i,2)==0 && mod(j,2) ==0 && mod(k,2)==0 && i==j && j==k)
         fprintf('%d \t %d \t %d \t %.4f \t %.4f \t %.4f  \t %.4f \t %.4f \t %.2E \n', ...
                 i, j, k, xout(i), yout(j), zout(k), vt3D(i,j,k), vout_apprx3D(i,j,k), abs(vt3D(i,j,k)-vout_apprx3D(i,j,k)) );
        end
      end
    end
  end
  fprintf('-------------------------------------------------------------------------------------------------------------------\n')
  fprintf('The maximum error is   %.2E \n \n \n', max(max(max(abs(vt3D-vout_apprx3D)))) );



