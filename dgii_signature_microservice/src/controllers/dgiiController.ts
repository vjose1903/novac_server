import { Request, Response } from 'express';
import { DgiiEcfService } from '@core/services/DgiiEcf.service';
import { ResponseApi } from '@utils/typescript/responseApi';
import { DgiiReceptionService } from '@core/services/DgiiReception.service';
import { DgiiCommercialApprovalService } from '@core/services/DgiiCommercialApproval.service';
import { DgiiAuthService } from '@core/services/DgiiAuth.service';

export class DgiiController {
  public static handleNovacDgiiRequest = async (req: Request, res: Response) => {
    const response = new ResponseApi(res);

    try {
      const dgiiEcfService = DgiiEcfService.getInstance();
      const jsonData = req.body;

      // Agregar la tarea a la cola y esperar a que termine
      dgiiEcfService
        .addToQueue(jsonData)
        .then(resp => {
          const { success, message, data, ...res } = resp;

          response.add_status(200).add_msg(message).add_data(data).send();
        })
        .catch(error => {
          console.error('error >>>', error);
          const { message, ...res } = error;
          response
            .add_status(500)
            .add_msg(message)
            .add_data({ ...res })
            .send();
        });
    } catch (error) {
      console.error(error);
      response.add_status(500).add_msg('Error procesando la solicitud').add_data({ error }).send();
    }
  };

  public static handleNovacDgiiReception = async (req: Request, res: Response) => {
    const response = new ResponseApi(res);

    try {
      const dgiiReceptionService = DgiiReceptionService.getInstance();

      dgiiReceptionService
        .addToQueue(req.body)
        .then(resp => {
          const { success, message, data, ...res } = resp;

          // response.add_status(200).add_msg(message).add_data(data).send();
          response.add_status(200).add_msg('Solicitud procesada correctamente').add_data(data).send();
        })
        .catch(error => {
          console.error('error >>>', error);
          const { message, ...res } = error;

          response
            .add_status(500)
            .add_msg(message)
            .add_data({ ...res })
            .send();
        });
    } catch (error) {
      console.error(error);
      response.add_status(500).add_msg('Error procesando la solicitud').add_data({ error }).send();
    }
  };

  public static handleNovacDgiiValidateCommercialApproval = async (req: Request, res: Response) => {
    const response = new ResponseApi(res);

    try {
      const dgiiCommercialApprovalService = DgiiCommercialApprovalService.getInstance();

      dgiiCommercialApprovalService
        .addToQueue(req.body)
        .then(resp => {
          const { success, message, data, ...res } = resp;

          response.add_status(200).add_msg('Solicitud procesada correctamente').add_data(data).send();
        })
        .catch(error => {
          console.error('error >>>', error);
          const { message, ...res } = error;

          response
            .add_status(400)
            .add_msg(message)
            .add_data({ ...res })
            .send();
        });
    } catch (error) {
      console.error(error);
      response.add_status(500).add_msg('Error procesando la solicitud').add_data({ error }).send();
    }
  };

  public static handleNovacDgiiTestAuthentication = async (req: Request, res: Response) => {
    const response = new ResponseApi(res);

    try {
      const dgiiAuthService = DgiiAuthService.getInstance();

      dgiiAuthService
        .testAuthentication()
        .then(resp => {
          response.add_status(200).add_msg('Test de autenticación exitoso').add_data(resp).send();
        })
        .catch(error => {
          console.error('error >>>', error);
          const { message, ...res } = error;

          response
            .add_status(500)
            .add_msg(message)
            .add_data({ ...res })
            .send();
        });
    } catch (error) {
      console.error(error);
      response.add_status(500).add_msg('Error procesando la solicitud').add_data({ error }).send();
    }
  };
}
