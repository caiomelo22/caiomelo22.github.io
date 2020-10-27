pragma solidity >=0.4.19 <0.7.0;


contract Apostas {
    constructor(uint _valor) public {
        dono_contrato = msg.sender;
        valor_aposta = _valor;
    }
    
    fallback() external { revert(); }

    address dono_contrato;
    uint valor_aposta;
    uint total_apostadores;
    address apostadorA;
    address apostadorB;
    
    struct Resultado {
        uint gols_time_A;
        uint gols_time_B;
    }

    mapping (address => Resultado) apostas_resultado;
    mapping (address => uint) vencedores;

    function realizaAposta(uint _gols_time_A, uint _gols_time_B) public payable returns (bool) {
        require(
            total_apostadores == 0 || total_apostadores ==1,
            "A aposta já está composta por 2 apostadores"
        );
        require(
            msg.value == valor_aposta,
            "Valor diferente do valor da aposta"
        );
        Resultado memory resultado = Resultado(_gols_time_A, _gols_time_B);
        if(total_apostadores == 0)
        {
            apostadorA = msg.sender;
        }
        else
        {
            apostadorB = msg.sender;
        }
        total_apostadores += 1;
        apostas_resultado[msg.sender] = resultado;
        return true;
    }

    function defineResultado(uint _gols_time_A, uint _gols_time_B) public {
        require(
            msg.sender == dono_contrato,
            "Somente o dono do contrato pode fazer a definição de resultado"
        );
        Resultado memory resultado = Resultado(_gols_time_A, _gols_time_B);
        
        if((apostas_resultado[apostadorA].gols_time_A == resultado.gols_time_A && apostas_resultado[apostadorA].gols_time_B == resultado.gols_time_B) 
            && (apostas_resultado[apostadorB].gols_time_A != resultado.gols_time_A || apostas_resultado[apostadorB].gols_time_B != resultado.gols_time_B))
        {
            vencedores[apostadorA] = valor_aposta * 2;
        }
        else if ((apostas_resultado[apostadorA].gols_time_A == resultado.gols_time_A && apostas_resultado[apostadorA].gols_time_B == resultado.gols_time_B) 
            && (apostas_resultado[apostadorB].gols_time_A == resultado.gols_time_A && apostas_resultado[apostadorB].gols_time_B == resultado.gols_time_B))
        {
            vencedores[apostadorA] = valor_aposta;
            vencedores[apostadorB] = valor_aposta;
        }
        else if ((apostas_resultado[apostadorA].gols_time_A != resultado.gols_time_A || apostas_resultado[apostadorA].gols_time_B != resultado.gols_time_B) 
            && (apostas_resultado[apostadorB].gols_time_A == resultado.gols_time_A && apostas_resultado[apostadorB].gols_time_B == resultado.gols_time_B))
        {
            vencedores[apostadorB] = valor_aposta*2;
        }
    }

    function retirarLucro() public returns (uint) {
        if (vencedores[msg.sender] >= 0) {
            msg.sender.transfer(vencedores[msg.sender]);
            vencedores[msg.sender] = 0;
        }
    }
    
    function getValorAposta() public view returns (uint) {
        return valor_aposta;
    }
    
    function checaLucro() public view returns(uint) {
        return vencedores[msg.sender];
    }
}