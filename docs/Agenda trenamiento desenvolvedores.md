**Entrenamiento Intensivo para Desarrolladores: Migración Sensedia a Kong Enterprise**

**Duración Total:** 8 horas (puede dividirse en 2 sesiones de 4 horas o 1 jornada completa).
**Audiencia:** Desarrolladores backend, integradores y desarrolladores de APIs.
**Objetivo:** Introducir la plataforma Kong Konnect, montar un entorno de trabajo funcional y resolver de forma nativa todos los desafíos técnicos mapeados en la migración de Sensedia (gestión de tokens, control de acceso, seguridad WAF y reemplazo de scripts Lua).

---

### **Requisitos Previos**
Para la ejecución práctica, cada desarrollador deberá contar con:
*   **Git** instalado para clonar el repositorio base.
*   **Docker Desktop** (o Docker Engine + Compose v2) corriendo localmente para provisionar los simuladores (mocks), el Gateway y la interfaz visual de Jaeger.
*   **CLI de Kong (decK)** instalada para aplicar configuraciones de forma puramente declarativa.
*   **Acesso a Internet** liberado para comunicación segura (Outbound TLS) por el puerto 443 con el Control Plane de Kong Konnect (SaaS).

---

### **Agenda del Entrenamiento (8 Horas)**

#### **Módulo 1: Introducción a Konnect y Setup del Ambiente (2 horas)**
*   **Conceptos Base:** Introducción al modelo de operación de Kong Konnect, comprendiendo la separación arquitectónica entre el Control Plane (SaaS) y el Data Plane.
*   **Setup Práctico:** Despliegue de un Data Plane local híbrido usando Docker Compose, integrado directamente al Control Plane SaaS corporativo.
*   **Emulación del Entorno:** Integración del Gateway con servidores de eco (Mocks de Backend), Jaeger (para visualización de traces emulando Datadog) y Keycloak (simulando localmente el Identity Provider interno *Hefesto*).

#### **Módulo 2: Motor Avanzado de Ruteo y Expressions (1.5 horas)**
*   **Ruteo Declarativo:** Uso de la CLI `decK` para gestionar y sincronizar rutas y servicios, reemplazando las configuraciones manuales del antiguo gateway.
*   **Motor ATC y Regex:** Resolución nativa de la captura de parámetros dinámicos complejos en la URL (por ejemplo, extraer `{product_key}` del path). Utilizaremos el potente motor de *Expressions* de Kong para estandarizar las rutas y asegurar la compatibilidad exacta con los endpoints actuales.

#### **Módulo 3: Autenticación y Estrategia Zero-Atrito para Tokens Legados (1.5 horas)**
*   **Proxy OIDC y Hefesto:** Abordaremos el reemplazo del plugin OAuth2 de Sensedia. Se configurará el Gateway como un proxy transparente usando el plugin nativo `openid-connect` para integrarse con Hefesto, extrayendo *claims* y validando identidades sin necesidad de código personalizado.
*   **Estrategia Zero-Atrito:** Implementación de dos alternativas para garantizar que la migración sea imperceptible para los clientes (sin forzar reautenticaciones):
    1.  **Validación Stateless:** Validación local y en tiempo real de los JWTs actuales preexistentes, apuntando la firma criptográfica directamente al Auth Server.
    2.  **Importación en Massa (Seed):** Uso de la API Admin de Kong para inyectar *access_tokens* opacos heredados de la base de Sensedia (manteniendo sus tiempos de expiración), permitiendo a las aplicaciones seguir enviando el mismo header `Authorization: Bearer`.

#### **Módulo 4: Seguridad Web y Control de Acceso Granular (1.5 horas)**
*   **Aislamiento de Rutas por Consumidor:** Resolución de la restricción de APIs individuales. Implementaremos Listas de Control de Acceso nativas (*ACL*) en conjunto con el plugin `key-auth` para denegar peticiones a un token válido si dicho consumidor no pertenece al grupo autorizado para una ruta específica.
*   **Protección Edge WAF:** Reemplazo de los interceptores globales de Sensedia contra inyecciones SQL (SQLi) y Cross-Site Scripting (XSS). Aplicaremos el plugin `request-validator` directamente en la borda para bloquear automáticamente cargas útiles maliciosas con un HTTP 400 Bad Request, garantizando la seguridad sin lógicas customizadas.

#### **Módulo 5: Eliminación de Deuda Técnica y Observabilidad (1.5 horas)**
*   **El "Kong-Way" (Sustituyendo scripts Lua):** Demostración práctica de cómo reducir el esfuerzo estimado de reescribir scripts heredados (calculado previamente en más de 25 días) utilizando exclusivamente plugins nativos de Konnect:
    *   **Transformación de Headers y Payload:** Uso avanzado del plugin `request-transformer` para manipular e inyectar identificadores posicionales (como mapear `{product_key}` hacia el header `x-product-key`) de forma automatizada.
    *   **Identidad M2M:** Implementación del patrón *Relying Party* para obtener tokens Machine-to-Machine y despacharlos hacia servicios financieros internos.
*   **Observabilidad y Tracing:** Sustitución del plugin Lua de `trace-id`. Inyectaremos identificadores estándar del W3C (`correlation-id` y `traceparent`) y exportaremos las trazas en formato OTLP usando el plugin `opentelemetry` hacia el agente de Datadog/Jaeger, logrando visibilidad completa sin instrumentación paralela.
*   **Q&A y Cierre:** Modelado general del despliegue masivo y automatizado hacia los entornos de producción.