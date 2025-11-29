function dydt = doble_pozo_general_ode(t, y, a, b)
    
    dydt = zeros(2, 1);
    
    % Ecuación 1: dx/dt = v
    dydt(1) = y(2);
    
    % Ecuación 2: dv/dt = 2bx - 4ax^3
    dydt(2) = 2*b*y(1) - 4*a*y(1)^3;
end

% --- Script Principal para el Análisis Paramétrico (Pregunta 7) ---
clc;
clear;
close all;

% Definición de los casos a estudiar:

parametros = [
     0.25, 0.0;
    0.25, 0.5;   % Caso 1: Base (a=1/4, b=1/2)
    0.25, 0.25;  % Caso 2: Menor b (barrera más baja)
    0.25, 1.0;   % Caso 3: Mayor b (barrera más alta)
     0.25, 0.8;
    0.1,  0.5;   % Caso 4: Menor a (pozos más cerca, barrera más baja)
    0.5,  0.5 ;   % Caso 5: Mayor a (pozos más lejos, barrera más alta)
    1.5,  0.5 ;
];

num_casos = size(parametros, 1);

% Inicialización de la tabla de resultados
resultados = table('Size', [num_casos, 6], ...
                   'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'string'}, ...
                   'VariableNames', {'a', 'b', 'T_s', 'A_m', 'f_Hz', 'Observacion'});

% --- Parámetros de Simulación Comunes ---
tspan = [0 100];      % Intervalo de tiempo [0, 100]
x0 = -1.5;            % Posición inicial (Fija, alta energía)
v0 = 0;               % Velocidad inicial (Fija)
y0 = [x0; v0];        % Vector de condiciones iniciales



colores = lines(num_casos); % Colores para diferenciar las órbitas

for i = 1:num_casos
    a = parametros(i, 1);
    b = parametros(i, 2);
    
    % Resolución de la EDO usando ode45. 
    [t, y] = ode45(@(t, y) doble_pozo_general_ode(t, y, a, b), tspan, y0);
    
    x = y(:, 1);  % Posición
    v = y(:, 2);  % Velocidad
    
    % --- 1. Cálculo de Amplitud (A) ---
    Amplitud = max(x); 
    
    % --- 2. Cálculo del Periodo (T) ---
    [pks, locs] = findpeaks(x, t);
    
    Periodo = NaN;
    Frecuencia = NaN;
    observacion_texto = 'Movimiento Global (Entre pozos)';
    
    if length(locs) >= 2
        % T es el tiempo entre dos picos
        Periodo = locs(2) - locs(1); 
        Frecuencia = 1 / Periodo;
    else
        % Caso donde no hay suficiente oscilación (puede ser confinamiento extremo)
        observacion_texto = 'No se detecta movimiento periódico.';
    end

    % --- Chequeo de confinamiento ---
    % Si la amplitud es menor que la posición de equilibrio estable, el movimiento es raro o confinado
    x_eq_estable = sqrt(b / (2*a));
    if Amplitud < 1.0 && x_eq_estable > 0.1 % Heurística simple para detectar confinamiento
         if x_eq_estable < 1.5
             observacion_texto = 'Movimiento Confinado (Baja energía)';
         end
    end

    % Almacenar resultados
    resultados.a(i) = a;
    resultados.b(i) = b;
    resultados.T_s(i) = Periodo;
    resultados.A_m(i) = Amplitud;
    resultados.f_Hz(i) = Frecuencia;
    resultados.Observacion{i} = observacion_texto;

end



% Mostrar tabla de resultados
disp(' ');
disp('--- Tabla de Resultados del Análisis Paramétrico (Pregunta 7) ---');
disp(resultados);

% Función para graficar los potenciales
function graficar_potenciales_comparativos()
    fprintf('\n=== GENERANDO GRÁFICOS COMPARATIVOS ===\n');
    
    parametros = [
        0.25, 0.5;
        0.25, 0.25;
        0.25, 1.0;
        0.1,  0.5;
        0.5,  0.5;
        
    ];
    
    colores = ['r', 'g', 'b', 'm', 'c'];
    x = linspace(-2, 2, 1000);
    
    figure('Position', [100, 100, 1200, 800]);
    
    for i = 1:size(parametros, 1)
        a = parametros(i, 1);
        b = parametros(i, 2);
        
        V = a*x.^4 - b*x.^2;
        
        subplot(2, 3, i);
        plot(x, V, colores(i), 'LineWidth', 2);
        hold on;
        
        % Marcar mínimos
        x_min = sqrt(b/(2*a));
        V_min = a*x_min^4 - b*x_min^2;
        plot([-x_min, x_min], [V_min, V_min], 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
        
        % Marcar condición inicial
        x0 = -1.5;
        V0 = a*x0^4 - b*x0^2;
        plot(x0, V0, 's', 'MarkerSize', 10, 'MarkerFaceColor', 'blue');
        
        title(sprintf('a=%.2f, b=%.2f', a, b));
        xlabel('x');
        ylabel('V(x)');
        grid on;
        legend('Potencial', 'Mínimos', 'Cond. Inicial', 'Location', 'best');
    end
    
    subplot(2, 3, 6);
    % Leyenda explicativa
    text(0.1, 0.7, 'LEYENDA:', 'FontSize', 12, 'FontWeight', 'bold');
    text(0.1, 0.6, '● Mínimos del potencial', 'FontSize', 10);
    text(0.1, 0.5, '■ Condición inicial (x₀=-1.5)', 'FontSize', 10);
    text(0.1, 0.4, '←→ Ancho entre pozos', 'FontSize', 10);
    text(0.1, 0.3, '↑↓ Profundidad de pozos', 'FontSize', 10);
    axis off;
    
    sgtitle('Comparación de Potenciales para Diferentes Parámetros a y b');
    
    fprintf('Gráficos generados. Revise la figura.\n');
end
graficar_potenciales_comparativos();