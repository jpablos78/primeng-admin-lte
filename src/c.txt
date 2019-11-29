<?php

include_once 'config.inc.php';
include_once 'ClaseBaseDatos.php';
include_once 'ClaseJson.php';
include_once 'funciones.php';

/**
 * Description of ClaseProcesarDocumentos
 *
 * @author jpsanchez
 */
class ClaseProcesarDocumentos {

    public function getDocumentos($parametros) {
        $select = "
        SELECT f.cci_empresa, 
        f.cno_empresa,
        f.cci_sucursal, 
        f.cci_cliente, 
        f.cno_cliprov,
        f.dfm_fecha,
        f.cci_tipocmpr, 
        f.descripcion_cci_tipocmpr,
        f.nci_documento,
        f.id_log_fe,
        f.cci_usuario,
        f.dfx_reg_fecha,
        f.ces_fe,
        f.descripcion_ces_fe,
        f.cci_clave_acceso
        FROM BIZ_FAC..VI_FAC_FE_DOCUMENTOS f ";

        $where = " WHERE cci_empresa != '' ";

        $selectTotalRegistros = "
            select count(*) as total_registros
            from BIZ_FAC..VI_FAC_FE_DOCUMENTOS
        ";

        $records = json_decode(stripslashes($parametros['filters']), true);

        foreach ($records as $k => $value) {
            $valor = '';
            $tmp = '';
            foreach ($value as $key => $_value) {

                if (is_array($_value)) {
                    $tmp = $_value;
                } else {
                    if ($key == 'value') {
                        $valor = $_value;
                    }
                }

                if ($key == 'matchMode') {
                    switch ($_value) {
                        case 'startsWith':
                            $where = $where . " AND " . $k . " like '$valor%' ";
                            break;
                        case 'contains':
                            $where = $where . " AND " . $k . " like '%$valor%' ";
                            break;
                        case 'equals':
                            if (is_array($tmp)) {
                                foreach ($tmp as $k2 => $v2) {
                                    if ($k2 == 'value') {
                                        $valor = $v2;
                                    }

                                    if ($k == 'estado_usuario' && $valor == 'T') {
                                        continue;
                                    }
                                }

                                $where = $where . " AND " . $k . " = '$valor' ";
                            } else {
                                $where = $where . " AND " . $k . " = '$valor' ";
                            }
                            break;
                        case 'in':
                            if (is_array($tmp)) {
                                $cadenaIn = " IN(";
                                foreach ($tmp as $valueIn) {
                                    $cadenaIn = $cadenaIn . "'$valueIn'";

                                    if (next($tmp) == true) {
                                        $cadenaIn = $cadenaIn . ",";
                                    } else {
                                        $cadenaIn = $cadenaIn . ") ";
                                    }
                                }
                                //echo $cadenaIn;
                                $where = $where . " AND " . $k . $cadenaIn;
                            }
                            break;
                    }
                }
            }
        }

        $start = $parametros['start'];

        $order = 'ORDER BY ' . $parametros['sortField'] . ' ';
        if ($parametros['sortOrder'] == '-1') {
            $order = $order . ' DESC ';
        }

        $offset = 'OFFSET ' . ($start) . ' ROWS ';
        $fetch = 'FETCH NEXT ' . $parametros['limit'] . ' ROWS ONLY';

        $queryTotalRegistros = $selectTotalRegistros . $where;
        $query = $select . $where . $order . $offset . $fetch;

        //echo $queryTotalRegistros;
        //echo $query;

        $parametros = array(
            'interfaz' => 'I',
            'query' => $queryTotalRegistros
        );

        $resultTotal = ClaseBaseDatos::query($parametros);


        if ($resultTotal['error'] == 'N') {
            $dataTotal = $resultTotal['data'];
            $totalRegistros = $dataTotal[0]['total_registros'];

            $parametros = array(
                'interfaz' => 'I',
                'query' => $query,
                'total' => $totalRegistros
            );

            $result = ClaseBaseDatos::query($parametros);

//            print_r($result);
            return $result;
        } else {
            return $resultTotal;
        }



//        $parametros = array(
//            'interfaz' => 'I',
//            'query' => $select
//        );
//
//        $result = ClaseBaseDatos::query($parametros);
//
//        return $result;
    }

}
