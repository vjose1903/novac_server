import { Request, Response } from 'express';
import { DgiiEcfService } from '@core/services/DgiiEcf.service';
import { ResponseApi } from '@utils/typescript/responseApi';
import { DgiiReceptionService } from '@core/services/DgiiReception.service';
import { DgiiCommercialApprovalService } from '@core/services/DgiiCommercialApproval.service';

export const handleNovacDgiiRequest = async (req: Request, res: Response) => {
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

export const handleNovacDgiiReception = async (req: Request, res: Response) => {
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

export const handleNovacDgiiValidateCommercialApproval = async (req: Request, res: Response) => {
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
