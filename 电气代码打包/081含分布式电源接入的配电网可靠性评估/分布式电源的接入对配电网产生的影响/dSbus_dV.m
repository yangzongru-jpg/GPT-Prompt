function [dSbus_dVm, dSbus_dVa] = dSbus_dV(Ybus, V)
%DSBUS_DV   求功率对电压的偏导数
%   [dSbus_dVm, dSbus_dVa] = dSbus_dV(Ybus, V) returns two matrices
%   containing
%   S = diag(V) * conj(Ibus) = diag(conj(Ibus)) * V
%       dV/dVm = diag(V./abs(V))
%       dI/dVm = Ybus * dV/dVm = Ybus * diag(V./abs(V))
%       dV/dVa = j * diag(V)
%       dI/dVa = Ybus * dV/dVa = Ybus * j * diag(V)
%       dS/dVm = diag(V) * conj(dI/dVm) + diag(conj(Ibus)) * dV/dVm
%              = diag(V) * conj(Ybus * diag(V./abs(V)))
%                                       + conj(diag(Ibus)) * diag(V./abs(V))
%       dS/dVa = diag(V) * conj(dI/dVa) + diag(conj(Ibus)) * dV/dVa
%              = diag(V) * conj(Ybus * j * diag(V))
%                                       + conj(diag(Ibus)) * j * diag(V)
%              = -j * diag(V) * conj(Ybus * diag(V))
%                                       + conj(diag(Ibus)) * j * diag(V)
%              = j * diag(V) * conj(diag(Ibus) - Ybus * diag(V))

n = length(V);
Ibus = Ybus * V;

if issparse(Ybus)           %% sparse version (if Ybus is sparse)
    diagV       = sparse(1:n, 1:n, V, n, n);
    diagIbus    = sparse(1:n, 1:n, Ibus, n, n);
    diagVnorm   = sparse(1:n, 1:n, V./abs(V), n, n);
else                        %% dense version
    diagV       = diag(V);
    diagIbus    = diag(Ibus);
    diagVnorm   = diag(V./abs(V));
end

dSbus_dVm = diagV * conj(Ybus * diagVnorm) + conj(diagIbus) * diagVnorm;
dSbus_dVa = 1j * diagV * conj(diagIbus - Ybus * diagV);