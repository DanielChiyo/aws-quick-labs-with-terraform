# VPC Peering 
Esta carpeta contiene configuraciones de Terraform que crea dos VPCs con todos los componentes necesarios en dos regiones de AWS para probar el VPC Peering.
También crea dos instancias de EC2 y Security Groups para pruebas.

## Diagrama del Estado Inicial de la Arquitectura
![Diagrama del Estado Inicial de la Arquitectura](vpc_peering_initial_state.png)

## Diagrama del Estado Final de la Arquitectura
![Diagrama del Estado Final de la Arquitectura](vpc_peering_final_state.png)


*Es posible modificar el código para realizar el peering en la misma región. Para ello, puedes editar el aws_vpc_peering_connection y eliminar el recurso aws_vpc_peering_connection_accepter en el archivo main.tf.

```hcl
resource "aws_vpc_peering_connection" "peer1" {
  vpc_id      = module.vpc_region1.vpc_id
  peer_vpc_id = module.vpc_region2.vpc_id
  auto_accept = true
}
```
