import { Response } from 'express';

export class ResponseApi {
  private _status: number;
  private _message: string;
  private _data: any;
  private _req: Response;

  constructor(req: Response) {
    this._req = req;
    this._status = 200;
    this._message = '';
    this._data = null;
  }

  add_status(status: number): ResponseApi {
    this._status = status;
    return this;
  }

  add_msg(message: string): ResponseApi {
    this._message = message;
    return this;
  }

  add_data(data: any): ResponseApi {
    this._data = data;
    return this;
  }

  send(): void {
    this._req.status(this._status).json({
      status: this._status,
      message: this._message,
      data: this._data
    });
  }
}


