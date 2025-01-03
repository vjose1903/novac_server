import * as forge from 'node-forge';
import * as xmldom from 'xmldom';
/*Referencias de librerias
 Node-forge: https://www.npmjs.com/package/node-forge#pkcs12
Xmldom: https://www.npmjs.com/package/xmldom
P12-pem:https://www.npmjs.com/package/p12-pem
 // Special character normalization:
 // - https://www.w3.org/TR/xml-c14n#ProcessingModel (Attribute / Text)
 // - https://www.w3.org/TR/xml-c14n#Example-Chars
Estas librerias fueron probadas en Note.js v.14.16.0
*/

export class FirmaXMLService {
	constructor() {}
	/* El parametro xml:un string formateado en xml:
    ("<ECF><eNCF>E310000000001</eNCF></ECF>").
     El parametro certificado: tipo ArrayBuffer, puede provenir de un control fileUpload.
     El Password:es el valor de la clave del certificado.
    */
	//Método utilizado para generar la firma del xml.

	Firmar(xml: any, certifado: ArrayBuffer, password: string) {
		// Se Genera el PEM & PrivateKey del certificado
		let pem = this.convertToPem(certifado, password);
		let privateKey = forge.pki.privateKeyFromPem(pem.pemKey);
		//-----------------------------------------------------------

		// Se prepara la encriptacion del contenido del xml
		let md = forge.md.sha256.create();
		var xmlData2 = new xmldom.DOMParser().parseFromString(xml);

		// Canolizacion del tag SignedInfo para poder generar correctamente la firma del documento.
		var xmlCanolizadoData2 = this.c14nCanonicalization(xmlData2.firstChild, null);
		md.update(xmlCanolizadoData2.toString(), 'utf8');
		//------------------------------------------------------------

		// Se obtiene solo el contenido del en formato encode64 para luego asignar este valor a el tag DigestValue
		let messageDigest = forge.util.encode64(md.digest().data);
		//------------------------------------------------------------

		// Se construye el xml con el tag de firma integrado en este punto aun no se genera el tag SignatureValue
		let pemXMLFormat = this.obtenerPEMXMLFormat(pem.pemCertificate);
		let xmlSinFirmado = this.agregarEstructuraFirma(xmlCanolizadoData2.toString(), pemXMLFormat, messageDigest);

		// Se convierte a formato XML la transformacion anterior. Esta transformacion es necesaria para poder obtener la canolizacion del XML.
		var xmlData = new xmldom.DOMParser().parseFromString(xmlSinFirmado);

		// Canolizacion del tag SignedInfo para poder generar correctamente la firma del documento.
		var xmlCanolizado = this.c14nCanonicalization(xmlData.getElementsByTagName('SignedInfo')[0], { defaultNsForPrefix: { ds: 'http://www.w3.org/2000/09/xmldsig#' } });

		// Generación de firma,
		md = forge.md.sha256.create();
		md.update(xmlCanolizado.toString(), 'utf8');
		let signature = privateKey.sign(md);
		//-----------------------------------------------------------------------------

		//Agregando firma a el xml generado con el formato de firma.
		let signatureValue = `<SignatureValue>${forge.util.encode64(signature)}</SignatureValue>`;

		const closeTagSignedInfo = '</SignedInfo>'
		let indiceFirma = xmlSinFirmado.search(closeTagSignedInfo);
		const signatureWriteIndex =  indiceFirma + closeTagSignedInfo.length
		let xmlFirmado = xmlSinFirmado.substring(0, signatureWriteIndex) + signatureValue + xmlSinFirmado.substring(signatureWriteIndex);

		let resultadoFirma = {
			xmlFirmadoString: xmlFirmado,
			xmlFirmadoBlob: this.generarBlobArchivoFirmado(xmlFirmado),
		};
		return resultadoFirma;
	}

	// Método que recibe un xml y retorna un archivo blob.
	private generarBlobArchivoFirmado(xmlFirmado: string) {
		let blob = new Blob([xmlFirmado], { type: 'text/xml;charset=utf-8' });

		return blob;
	}

	//Sirve para obtener el formato del Pem
	private obtenerPEMXMLFormat(PEM: any) {
		let PEMToXmlFormat = PEM.replace('-----BEGIN CERTIFICATE-----', '');
		PEMToXmlFormat = PEMToXmlFormat.replace('-----END CERTIFICATE-----', '');
		return PEMToXmlFormat;
	}

	//Permite generar la estructura del area de la firma en formato de la estructura del xml
	private agregarEstructuraFirma(xml: string, PEM: any, digestValue: string) {
		const firmaStructure = `<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
        <SignedInfo>
            <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
            <SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" />
            <Reference URI="">
                <Transforms>
                    <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
                </Transforms>
                <DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" />
                <DigestValue>${digestValue}</DigestValue>
            </Reference>
        </SignedInfo>
        <KeyInfo>
            <X509Data>
                <X509Certificate>${PEM}</X509Certificate>
            </X509Data>
        </KeyInfo>
    </Signature>`;

		let indice = xml.search('</ECF>');

		if(!indice || indice == -1) indice = xml.search('</SemillaModel>')


		let xmlSinFirmado = xml.substring(0, indice) + firmaStructure + xml.substring(indice);

		return xmlSinFirmado;
	}

	//Permite convertir a Pem
	private convertToPem(p12ArrayBuffer: ArrayBuffer, password: string) {
		// // Convierte el ArrayBuffer en un Uint8Array
		// const byteArray = new Uint8Array(p12ArrayBuffer);

		// // Convierte el Uint8Array a una cadena binaria
		// const binaryString = Array.from(byteArray).map(byte => String.fromCharCode(byte)).join('');

		let p12Asn1 = forge.asn1.fromDer(p12ArrayBuffer);
		let p12 = forge.pkcs12.pkcs12FromAsn1(p12Asn1, false, password);
		let pemKey = this.getKeyFromP12(p12, password);
		let _a = this.getCertificateFromP12(p12);
		let pemCertificate = _a.pemCertificate;
		let commonName = _a.commonName;

		return { pemKey: pemKey, pemCertificate: pemCertificate, commonName: commonName };
	}

	// Obtiene la llave de un p12
	private getKeyFromP12(p12, password) {
		var keyData = p12.getBags({ bagType: forge.pki.oids.pkcs8ShroudedKeyBag }, password);
		var pkcs8Key = keyData[forge.pki.oids.pkcs8ShroudedKeyBag][0];
		if (typeof pkcs8Key === 'undefined') {
			pkcs8Key = keyData[forge.pki.oids.keyBag][0];
		}
		if (typeof pkcs8Key === 'undefined') {
			throw new Error('Unable to get private key.');
		}
		var pemKey = forge.pki.privateKeyToPem(pkcs8Key.key);
		pemKey = pemKey.replace(/\r\n/g, '');
		return pemKey;
	}

	// Para obtener el certificado de un p12
	private getCertificateFromP12(p12) {
		var certData = p12.getBags({ bagType: forge.pki.oids.certBag });
		var certificate = certData[forge.pki.oids.certBag][0];
		var pemCertificate = forge.pki.certificateToPem(certificate.cert);
		pemCertificate = pemCertificate.replace(/\r\n/g, '');
		var commonName = certificate.cert.subject.attributes[0].value;
		return { pemCertificate: pemCertificate, commonName: commonName };
	}

	// Utilizado para poder realizar la canonicalización de etiquetas del xml.
	private c14nCanonicalization = function (node, options) {
		options = options || {};
		let defaultNs = options.defaultNs || '';
		let defaultNsForPrefix = options.defaultNsForPrefix || {};
		let ancestorNamespaces = options.ancestorNamespaces || [];

		let res = this.c14nCanonicalizationInterno(node, [], defaultNs, defaultNsForPrefix, ancestorNamespaces);
		return res;
	};

	private c14nCanonicalizationInterno = function (node, prefixesInScope, defaultNs, defaultNsForPrefix, ancestorNamespaces) {
		if (node.nodeType === 8) return this.renderComment(node);

		if (node.data) return this.encodeSpecialCharactersInText(node.data);

		let i;
		let pfxCopy;
		let ns = this.renderNs(node, prefixesInScope, defaultNs, defaultNsForPrefix, ancestorNamespaces);
		let res = ['<', node.tagName, ns.rendered, this.renderAttrs(node, ns.newDefaultNs), '>'];

		for (i = 0; i < node.childNodes.length; ++i) {
			pfxCopy = prefixesInScope.slice(0);
			res.push(this.c14nCanonicalizationInterno(node.childNodes[i], pfxCopy, ns.newDefaultNs, defaultNsForPrefix, []));
		}
		res.push('</', node.tagName, '>');
		return res.join('');
	};

	private renderComment = function (node) {
		if (!this.includeComments) {
			return '';
		}
		var isOutsideDocument = node.ownerDocument === node.parentNode,
			isBeforeDocument: boolean | null = null,
			isAfterDocument: boolean | null = null;
		if (isOutsideDocument) {
			var nextNode = node,
				previousNode = node;
			while (nextNode !== null) {
				if (nextNode === node.ownerDocument.documentElement) {
					isBeforeDocument = true;
					break;
				}
				nextNode = nextNode.nextSibling;
			}
			while (previousNode !== null) {
				if (previousNode === node.ownerDocument.documentElement) {
					isAfterDocument = true;
					break;
				}
				previousNode = previousNode.previousSibling;
			}
		}
		return (isAfterDocument ? '\n' : '') + '<!--' + this.encodeSpecialCharactersInText(node.data) + '-->' + (isBeforeDocument ? '\n' : '');
	};

	private renderAttrs = function (node, defaultNS) {
		var a: any;
		let i: any;
		let attr: any;
		let res: any = [];
		let attrListToRender: any = [];

		if (node.nodeType === 8) {
			return this.renderComment(node);
		}
		if (node.attributes) {
			for (i = 0; i < node.attributes.length; ++i) {
				attr = node.attributes[i];
				// Para ignorar los atributos de definición del espacio de nombres.
				if (attr.name.indexOf('xmlns') === 0) {
					continue;
				}
				attrListToRender.push(attr);
			}
		}
		attrListToRender.sort(this.attrCompare);

		for (a in attrListToRender) {
			if (!attrListToRender.hasOwnProperty(a)) {
				continue;
			}
			attr = attrListToRender[a];
			res.push(' ', attr.name, '="', this.encodeSpecialCharactersInAttribute(attr.value), '"');
		}

		return res.join('');
	};

	private renderNs = function (node, prefixesInScope, defaultNs, defaultNsForPrefix, ancestorNamespaces) {
		let a: any;
		let i: any;
		let p: any;
		let attr: any;
		let res: any = [];
		let newDefaultNs: any = defaultNs;
		let nsListToRender: any = [];
		let currNs: any = node.namespaceURI || '';

		// Utilizado para manejar el espacio de nombres del propio nodo
		if (node.prefix) {
			if (prefixesInScope.indexOf(node.prefix) == -1) {
				nsListToRender.push({ prefix: node.prefix, namespaceURI: node.namespaceURI || defaultNsForPrefix[node.prefix] });
				prefixesInScope.push(node.prefix);
			}
		} else if (defaultNs != currNs) {
			//nuevo por defecto ns.
			newDefaultNs = node.namespaceURI;
			res.push(' xmlns="', newDefaultNs, '"');
		}

		// Utilizado para manejar el espacio de nombres de los atributos.
		if (node.attributes) {
			for (i = 0; i < node.attributes.length; ++i) {
				attr = node.attributes[i];

				// Para manejar todos los atributos prefijados que están incluidos en la lista de prefijos y donde el prefijo aún no está definido.
				// Los nuevos prefijos solo se pueden definir mediante `xmlns:`.
				if (attr.prefix === 'xmlns' && prefixesInScope.indexOf(attr.localName) === -1) {
					nsListToRender.push({ prefix: attr.localName, namespaceURI: attr.value });
					prefixesInScope.push(attr.localName);
				}

				//Manejar todos los atributos prefijados que no son definiciones xmlns.
				//Donde el prefijo no está definido .
				if (attr.prefix && prefixesInScope.indexOf(attr.prefix) == -1 && attr.prefix != 'xmlns' && attr.prefix != 'xml') {
					nsListToRender.push({ prefix: attr.prefix, namespaceURI: attr.namespaceURI });

					prefixesInScope.push(attr.prefix);
				}
			}
		}

		if (Array.isArray(ancestorNamespaces) && ancestorNamespaces.length > 0) {
			// Eliminar espacios de nombres que ya están presentes en nsListToRender
			for (var p1 in ancestorNamespaces) {
				if (!ancestorNamespaces.hasOwnProperty(p1)) continue;
				var alreadyListed = false;
				for (var p2 in nsListToRender) {
					if (nsListToRender[p2].prefix === ancestorNamespaces[p1].prefix && nsListToRender[p2].namespaceURI === ancestorNamespaces[p1].namespaceURI) {
						alreadyListed = true;
					}
				}

				if (!alreadyListed) {
					nsListToRender.push(ancestorNamespaces[p1]);
				}
			}
		}

		nsListToRender.sort(this.nsCompare);

		//renderizar espacios de nombres
		for (a in nsListToRender) {
			if (!nsListToRender.hasOwnProperty(a)) {
				continue;
			}

			p = nsListToRender[a];
			res.push(' xmlns:', p.prefix, '="', p.namespaceURI, '"');
		}

		return { rendered: res.join(''), newDefaultNs: newDefaultNs };
	};

	// Obtiene el texto de caracteres encodeados
	private static get_xml_special_to_encoded_text(attributeValue) {
		var xml_special_to_encoded_attribute = {
			'&': '&amp;',
			'<': '&lt;',
			'"': '&quot;',
			'\r': '',
			'\n': '',
			'\t': '&#x9;',
			"'": '&apos;',
			'>': '&gt;',
		};
		return xml_special_to_encoded_attribute[attributeValue];
	}

	// Encodear caracteres especiales en texto
	private encodeSpecialCharactersInText(text) {
		var _text = text;
		return text.replace(/([&<>\r])/g, function (str, item) {
			return FirmaXMLService.get_xml_special_to_encoded_text(item);
		});
	}

	// Encodear caracteres especiales en atributos
	private encodeSpecialCharactersInAttribute(attributeValue) {
		return attributeValue.replace(/([&<"\r\n\t])/g, function (str, item) {
			return FirmaXMLService.get_xml_special_to_encoded_text(item);
		});
	}
}
